(*  
  File:       Bernoulli.thy
  Author:     Lukas Bulwahn <lukas.bulwahn-at-gmail.com> 
  Author:     Manuel Eberl <eberlm@in.tum.de> 
*)
section \<open>Bernoulli numbers\<close>

theory Bernoulli
imports Complex_Main
begin

subsection \<open>Preliminaries\<close>
  
lemma power_numeral_reduce: "a ^ numeral n = a * a ^ pred_numeral n"
  by (simp only: numeral_eq_Suc power_Suc)

lemma fact_diff_Suc: "n < Suc m \<Longrightarrow> fact (Suc m - n) = of_nat (Suc m - n) * fact (m - n)"
  by (subst fact_reduce) auto

lemma of_nat_binomial_Suc:
  assumes "k \<le> n"
  shows   "of_nat (Suc n choose k) = of_nat (Suc n) / of_nat (Suc n - k) * real (n choose k)"
  using assms by (simp add: binomial_fact divide_simps fact_diff_Suc of_nat_diff)

lemma integrals_eq:
  assumes "f 0 = g 0"
  assumes "\<And> x. ((\<lambda>x. f x - g x) has_real_derivative 0) (at x)"
  shows "f x = g x"
proof -
  show "f x = g x"
  proof (cases "x \<noteq> 0")
    case True
    from assms DERIV_const_ratio_const[OF this, of "\<lambda>x. f x - g x" 0]
    show ?thesis by auto
  qed (simp add: assms)
qed

lemma sum_diff: "((\<Sum>i\<le>n::nat. f (i + 1) - f i)::'a::field) = f (n + 1) - f 0"
  by (induct n) (auto simp add: field_simps)


subsection \<open>Bernoulli Numbers and Bernoulli Polynomials\<close>

declare sum.cong [fundef_cong]

fun bernoulli :: "nat \<Rightarrow> real"
where
  "bernoulli 0 = (1::real)"
| "bernoulli (Suc n) =  (-1 / (n + 2)) * (\<Sum>k \<le> n. ((n + 2 choose k) * bernoulli k))"
  
declare bernoulli.simps[simp del]
  
lemmas bernoulli_0 [simp] = bernoulli.simps(1)
lemmas bernoulli_Suc = bernoulli.simps(2)
lemma bernoulli_1 [simp]: "bernoulli 1 = -1/2" by (simp add: bernoulli_Suc)
lemma bernoulli_Suc_0 [simp]: "bernoulli (Suc 0) = -1/2" by (simp add: bernoulli_Suc)

definition
  "bernpoly n = (\<lambda>x. \<Sum>k \<le> n. (n choose k) * bernoulli k * x ^ (n - k))"
  
lemma bernpoly_altdef:
  "bernpoly n = (\<lambda>x. \<Sum>k\<le>n. real (n choose k) * bernoulli (n - k) * x ^ k)"
proof
  fix x
  have "bernpoly n x = (\<Sum>k\<le>n. real (n choose (n - k)) * bernoulli (n - k) * x ^ (n - (n - k)))"
    unfolding bernpoly_def by (rule sum.reindex_bij_witness[of _ "\<lambda>k. n - k" "\<lambda>k. n - k"]) simp_all
  also have "\<dots> = (\<Sum>k\<le>n. real (n choose k) * bernoulli (n - k) * x ^ k)"
    by (intro sum.cong refl) (simp_all add: binomial_symmetric [symmetric])
  finally show "bernpoly n x = \<dots>" .
qed

lemma bernoulli_Suc': 
  "bernoulli (Suc n) = -1/(real n + 2) * (\<Sum>k\<le>n. real (n + 2 choose (k + 2)) * bernoulli (n - k))" 
proof -
  have "bernoulli (Suc n) = - 1 / (real n + 2) * (\<Sum>k\<le>n. real (n + 2 choose k) * bernoulli k)"
    unfolding bernoulli.simps ..
  also have "(\<Sum>k\<le>n. real (n + 2 choose k) * bernoulli k) = 
               (\<Sum>k\<le>n. real (n + 2 choose (n - k)) * bernoulli (n - k))"
    by (rule sum.reindex_bij_witness[of _ "\<lambda>k. n - k" "\<lambda>k. n - k"]) simp_all
  also have "\<dots> = (\<Sum>k\<le>n. real (n + 2 choose (k + 2)) * bernoulli (n - k))"
    by (intro sum.cong refl, subst binomial_symmetric) simp_all
  finally show ?thesis .
qed
  

subsection \<open>Basic Observations on Bernoulli Polynomials\<close>

lemma bernpoly_0 [simp]: "bernpoly n 0 = bernoulli n"
proof (cases n)
  case 0
  then show "bernpoly n 0 = bernoulli n"
    unfolding bernpoly_def bernoulli.simps by auto
next
  case (Suc n')
  have "(\<Sum>k\<le>n'. real (Suc n' choose k) * bernoulli k * 0 ^ (Suc n' - k)) = 0"
    by (rule sum.neutral) auto
  with Suc show ?thesis
    unfolding bernpoly_def by simp
qed 

lemma continuous_on_bernpoly [continuous_intros]: "continuous_on A (bernpoly n)"
  unfolding bernpoly_def by (auto intro!: continuous_intros)

lemma isCont_bernpoly [continuous_intros]: "isCont (bernpoly n) x"
  unfolding bernpoly_def by (auto intro!: continuous_intros)  

lemma has_field_derivative_bernpoly:
  "(bernpoly (Suc n) has_real_derivative ((n + 1) * bernpoly n x)) (at x)"
proof -
  have "(bernpoly (Suc n) has_real_derivative 
          (\<Sum>k\<le>n. real (Suc n - k) * x ^ (n - k) * (real (Suc n choose k) * bernoulli k))) (at x)"
    unfolding bernpoly_def by (rule DERIV_cong) (fast intro!: derivative_intros, simp)
  moreover have "(\<Sum>k\<le>n. real (Suc n - k) * x ^ (n - k) * (real (Suc n choose k) * bernoulli k)) =
                   real (n + 1) * bernpoly n x" unfolding bernpoly_def
    by (subst sum_distrib_left, intro sum.cong refl, subst of_nat_binomial_Suc)
       (simp_all add: field_simps del: of_nat_Suc)
  ultimately show ?thesis by (auto simp del: of_nat_Suc One_nat_def)
qed
  
lemmas has_field_derivative_bernpoly' [derivative_intros] =
  DERIV_chain'[OF _ has_field_derivative_bernpoly]    

lemma sum_binomial_times_bernoulli:
  "(\<Sum>k\<le>n. ((Suc n) choose k) * bernoulli k) = (if n = 0 then 1 else 0)"
proof (cases n)
  case (Suc m)
  then show ?thesis
    by (simp add: bernoulli_Suc)
       (simp add: field_simps add_2_eq_Suc'[symmetric] del: add_2_eq_Suc add_2_eq_Suc')
qed simp_all
  
lemma sum_binomial_times_bernoulli':
  "(\<Sum>k<n. real (n choose k) * bernoulli k) = (if n = 1 then 1 else 0)"
proof (cases n)
  case (Suc m)
  have "(\<Sum>k<n. real (n choose k) * bernoulli k) =
           (\<Sum>k\<le>m. real (Suc m choose k) * bernoulli k)"
    unfolding Suc lessThan_Suc_atMost ..
  also have "\<dots> = (if n = 1 then 1 else 0)" 
    by (subst sum_binomial_times_bernoulli) (simp add: Suc)
  finally show ?thesis .
qed simp_all
  
lemma binomial_unroll:
  "n > 0 \<Longrightarrow> (n choose k) = (if k = 0 then 1 else (n - 1) choose (k - 1) + ((n - 1) choose k))"
  by (auto simp add: gr0_conv_Suc)

lemma sum_unroll:
  "(\<Sum>k\<le>n::nat. f k) = (if n = 0 then f 0 else f n + (\<Sum>k\<le>n - 1. f k))"
  by (cases n) (simp_all add: add_ac)

lemma bernoulli_unroll:
  "n > 0 \<Longrightarrow> bernoulli n = - 1 / (real n + 1) * (\<Sum>k\<le>n - 1. real (n + 1 choose k) * bernoulli k)"
by (cases n) (simp add: bernoulli_Suc)+

lemmas bernoulli_unroll_all = binomial_unroll bernoulli_unroll sum_unroll bernpoly_def

lemma bernpoly_1_1: "bernpoly 1 1 = 1/2"
  by (simp add: bernoulli_unroll_all)


subsection \<open>Sum of Powers with Bernoulli Polynomials\<close>

lemma diff_bernpoly:
  "bernpoly n (x + 1) - bernpoly n x = n * x ^ (n - 1)"
proof (induct n arbitrary: x)
  case 0
  show ?case unfolding bernpoly_def by auto
next
  case (Suc n)
  have "bernpoly (Suc n) (0 + 1) - bernpoly (Suc n) 0 = (Suc n) * 0 ^ n"
    unfolding bernpoly_0 unfolding bernpoly_def by (simp add: sum_binomial_times_bernoulli zero_power)
  then have const: "bernpoly (Suc n) (0 + 1) - bernpoly (Suc n) 0 = real (Suc n) * 0 ^ n" by (simp add: power_0_left)
  have hyps': "\<And>x. (real n + 1) * bernpoly n (x + 1) - (real n + 1) * bernpoly n x = real n * x ^ (n - Suc 0) * real (Suc n)"
    unfolding right_diff_distrib[symmetric] by (simp add: Suc.hyps One_nat_def)
  note [derivative_intros] = DERIV_chain'[where f = "\<lambda>x::real. x + 1" and g = "bernpoly (Suc n)" and s="UNIV"]
  have derivative: "\<And>x. ((%x. bernpoly (Suc n) (x + 1) - bernpoly (Suc n) x - real (Suc n) * x ^ n) has_real_derivative 0) (at x)"
    by (rule DERIV_cong) (fast intro!: derivative_intros, simp add: hyps')
  from integrals_eq[OF const derivative] show ?case by simp
qed
  
lemma bernpoly_1:
  assumes "n \<noteq> 1"
  shows   "bernpoly n 1 = bernoulli n"
proof (cases "n \<ge> 2")
  case False
  with assms have "n = 0" by auto
  thus ?thesis by (simp add: bernpoly_def)
next
  case True
  with diff_bernpoly[of n 0] show ?thesis
    by (simp add: power_0_left bernpoly_0)
qed

theorem sum_of_powers: 
  "(\<Sum>k\<le>n::nat. (real k) ^ m) = (bernpoly (Suc m) (n + 1) - bernpoly (Suc m) 0) / (m + 1)"
proof -
  from diff_bernpoly[of "Suc m", simplified] have "(m + (1::real)) * (\<Sum>k\<le>n. (real k) ^ m) = (\<Sum>k\<le>n. bernpoly (Suc m) (real k + 1) - bernpoly (Suc m) (real k))"
    by (auto simp add: sum_distrib_left intro!: sum.cong)
  also have "... = (\<Sum>k\<le>n. bernpoly (Suc m) (real (k + 1)) - bernpoly (Suc m) (real k))"
    by (simp add: add_ac)
  also have "... = bernpoly (Suc m) (n + 1) - bernpoly (Suc m) 0"
    by (simp only: sum_diff[where f="\<lambda>k. bernpoly (Suc m) (real k)"]) simp
  finally show ?thesis by (auto simp add: field_simps intro!: eq_divide_imp)
qed
  
lemma sum_of_powers_nat_aux: 
  assumes "real a = b / c" "real b' = b" "real c' = c"
  shows   "a = b' div c'"
proof (cases "c = 0")
  case False 
  with assms have "real (a * c') = real b'" by (simp add: field_simps)
  hence "b' = a * c'" by (subst (asm) of_nat_eq_iff) simp
  with False assms show ?thesis by simp
qed (insert assms, simp_all)


subsection \<open>Instances for Square And Cubic Numbers\<close>

theorem sum_of_squares: "real (\<Sum>k\<le>n::nat. k ^ 2) = real (2 * n ^ 3 + 3 * n ^ 2 + n) / 6"
  by (simp only: of_nat_sum of_nat_power sum_of_powers)
     (simp add: bernoulli_unroll_all field_simps power2_eq_square power_numeral_reduce)

corollary sum_of_squares_nat: "(\<Sum>k\<le>n::nat. k ^ 2) = (2 * n ^ 3 + 3 * n ^ 2 + n) div 6"
  by (rule sum_of_powers_nat_aux[OF sum_of_squares]) simp_all

theorem sum_of_cubes: "real (\<Sum>k\<le>n::nat. k ^ 3) = real (n ^ 2 + n) ^ 2 / 4"
  by (simp only: of_nat_sum of_nat_power sum_of_powers)
     (simp add: bernoulli_unroll_all field_simps power2_eq_square power_numeral_reduce)
                       
corollary sum_of_cubes_nat: "(\<Sum>k\<le>n::nat. k ^ 3) = (n ^ 2 + n) ^ 2 div 4"
  by (rule sum_of_powers_nat_aux[OF sum_of_cubes]) simp_all

end
