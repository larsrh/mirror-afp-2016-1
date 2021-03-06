(*  Author:  Sébastien Gouëzel   sebastien.gouezel@univ-rennes1.fr
    License: BSD
*)

theory SG_Library_Complement
  imports "~~/src/HOL/Probability/Probability"
begin

section {*SG Libary complements*}

text {* In this file are included many statements that were useful to me, but belong rather
naturally to existing theories. In a perfect world, some of these statements would get included
into these files.

I tried to indicate to which of these classical theories the statements could be added.
*}

subsection {*Basic logic*}

text {* This one is certainly available, but I could not locate it... *}
lemma equiv_neg:
  "\<lbrakk> P \<Longrightarrow> Q; \<not>P \<Longrightarrow> \<not>Q \<rbrakk> \<Longrightarrow> (P\<longleftrightarrow>Q)"
by blast


subsection {*Basic set theory*}

abbreviation sym_diff :: "'a set \<Rightarrow> 'a set \<Rightarrow> 'a set" (infixl "\<Delta>" 70) where
  "sym_diff A B \<equiv> ((A - B) \<union> (B-A))"

text {* Not sure the next lemmas are useful, as they are proved solely by auto, so they
could be reproved automatically whenever necessary.*}

lemma sym_diff_inc:
  "A \<Delta> C \<subseteq> A \<Delta> B \<union> B \<Delta> C"
by auto

lemma sym_diff_vimage [simp]:
  "f-`(A \<Delta> B) = (f-`A) \<Delta> (f-`B)"
by auto

lemma card_finite_union:
  assumes "finite I"
  shows "card(\<Union>i\<in>I. A i) \<le> (\<Sum>i\<in>I. card(A i))"
using assms apply (induct, auto)
using card_Un_le nat_add_left_cancel_le order_trans by blast


subsection {*Set-Interval.thy*}

text{* The next two lemmas belong naturally to \verb+Set_Interval.thy+, next to
\verb+UN_le_add_shift+. They are not trivially equivalent to the corresponding lemmas
with large inequalities, due to the difference when $n=0$. *}

lemma UN_le_add_shift_strict:
  "(\<Union>i<n::nat. M(i+k)) = (\<Union>i\<in>{k..<n+k}. M i)" (is "?A = ?B")
proof
  show "?B \<subseteq> ?A"
  proof
    fix x assume "x \<in> ?B"
    then obtain i where i: "i \<in> {k..<n+k}" "x \<in> M(i)" by auto
    then have "i - k < n \<and> x \<in> M((i-k) + k)" by auto
    then show "x \<in> ?A" using UN_le_add_shift by blast
  qed
qed (fastforce)

lemma UN_le_eq_Un0_strict:
  "(\<Union>i<n+1::nat. M i) = (\<Union>i\<in>{1..<n+1}. M i) \<union> M 0" (is "?A = ?B")
proof
  show "?A \<subseteq> ?B"
  proof
    fix x assume "x \<in> ?A"
    then obtain i where i: "i<n+1" "x \<in> M i" by auto
    show "x \<in> ?B"
    proof(cases i)
      case 0 with i show ?thesis by simp
    next
      case (Suc j) with i show ?thesis by auto
    qed
  qed
qed (auto)

text {* I use repeatedly this one, but I could not find it directly *}

lemma union_insert_0:
  "(\<Union>n::nat. A n) = A 0 \<union> (\<Union>n\<in>{1..}. A n)"
by (metis UN_insert Un_insert_left sup_bot.left_neutral One_nat_def atLeast_0 atLeast_Suc_greaterThan ivl_disj_un_singleton(1))

text {*Next one could be close to \verb+sum_nat_group+*}

lemma sum_arith_progression:
  "(\<Sum>r<(N::nat). (\<Sum>i<a. f (i*N+r))) = (\<Sum>j<a*N. f j)"
proof -
  have *: "(\<Sum>r<N. f (i*N+r)) = (\<Sum> j \<in> {i*N..<i*N + N}. f j)" for i
    by (rule sum.reindex_bij_betw, rule bij_betw_byWitness[where ?f'= "\<lambda>r. r-i*N"], auto)

  have "(\<Sum>r<N. (\<Sum>i<a. f (i*N+r))) = (\<Sum>i<a. (\<Sum>r<N. f (i*N+r)))"
    using sum.commute by auto
  also have "... = (\<Sum>i<a. (\<Sum> j \<in> {i*N..<i*N + N}. f j))"
    using * by auto
  also have "... = (\<Sum>j<a*N. f j)"
    by (rule sum_nat_group)
  finally show ?thesis by simp
qed


subsection {*Miscellanous basic results*}

lemma ind_from_1 [case_names 1 Suc, consumes 1]:
  assumes "n > 0"
  assumes "P 1"
      and "\<And>n. n > 0 \<Longrightarrow> P n \<Longrightarrow> P (Suc n)"
  shows "P n"
proof -
  have "(n = 0) \<or> P n"
  proof (induction n)
    case 0 then show ?case by auto
  next
    case (Suc k)
    consider "Suc k = 1" | "Suc k > 1" by linarith
    then show ?case
      apply (cases) using assms Suc.IH by auto
  qed
  then show ?thesis using `n > 0` by auto
qed

lemma Inf_nat_def0:
  fixes K::"nat set"
  assumes "n\<in>K"
          "\<And> i. i<n \<Longrightarrow> i\<notin>K"
  shows "Inf K = n"
using assms cInf_eq_minimum not_less by blast

text{* This lemma is certainly available somewhere, but I couldn't
locate it *}

lemma tends_to_real_e:
  fixes u::"nat \<Rightarrow> real"
  assumes "u \<longlonglongrightarrow> l"
          "e>0"
  shows "\<exists>N. \<forall>n>N. abs(u n -l) < e"
proof-
  have "eventually (\<lambda>n. dist (u n) l < e) sequentially" using assms tendstoD by auto
  then have "\<forall>\<^sub>F n in sequentially. abs(u n - l) < e" using dist_real_def by auto
  then show ?thesis by (simp add: eventually_at_top_dense)
qed

lemma nat_mod_cong:
  assumes "a=b+(c::nat)"
          "a mod n = b mod n"
  shows "c mod n = 0"
proof -
  let ?k = "a mod n"
  obtain a1 where "a = a1*n + ?k" by (metis div_mult_mod_eq)
  moreover obtain b1 where "b = b1*n + ?k" using assms(2) by (metis div_mult_mod_eq)
  ultimately have "a1 * n + ?k = b1 * n + ?k + c" using assms(1) by arith
  then have "c = (a1 - b1) * n" by (simp add: diff_mult_distrib)
  then show ?thesis by simp
qed

text {*The next two lemmas are not directly equivalent, since $f$ might
not be injective.*}

lemma abs_Max_sum:
  fixes A::"real set"
  assumes "finite A" "A \<noteq> {}"
  shows "abs(Max A) \<le> (\<Sum>a\<in>A. abs(a))"
using assms by (induct rule: finite_ne_induct, auto)

lemma abs_Max_sum2:
  fixes f::"_ \<Rightarrow> real"
  assumes "finite A" "A \<noteq> {}"
  shows "abs(Max (f`A)) \<le> (\<Sum>a\<in>A. abs(f a))"
using assms by (induct rule: finite_ne_induct, auto)



subsection {*Topological-spaces.thy*}

text {*The next statements come from the same statements for true subsequences*}

lemma eventually_weak_subseq:
  fixes u::"nat \<Rightarrow> nat"
  assumes "(\<lambda>n. real(u n)) \<longlonglongrightarrow> \<infinity>" "eventually P sequentially"
  shows "eventually (\<lambda>n. P (u n)) sequentially"
proof -
  obtain N where *: "\<forall>n\<ge>N. P n" using assms(2) unfolding eventually_sequentially by auto
  obtain M where "\<forall>m\<ge>M. ereal(u m) \<ge> N" using assms(1) by (meson Lim_PInfty)
  then have "\<And>m. m \<ge> M \<Longrightarrow> u m \<ge> N" by auto
  then have "\<And>m. m \<ge> M \<Longrightarrow> P(u m)" using `\<forall>n\<ge>N. P n` by simp
  then show ?thesis unfolding eventually_sequentially by auto
qed

lemma filterlim_weak_subseq:
  fixes u::"nat \<Rightarrow> nat"
  assumes "(\<lambda>n. real(u n)) \<longlonglongrightarrow> \<infinity>"
  shows "LIM n sequentially. u n:> at_top"
unfolding filterlim_iff by (metis assms eventually_weak_subseq)

lemma limit_along_weak_subseq:
  fixes u::"nat \<Rightarrow> nat" and v::"nat \<Rightarrow> _"
  assumes "(\<lambda>n. real(u n)) \<longlonglongrightarrow> \<infinity>" "v \<longlonglongrightarrow> l"
  shows "(\<lambda> n. v(u n)) \<longlonglongrightarrow> l"
using filterlim_compose[of v, OF _ filterlim_weak_subseq] assms by auto

subsection {*Transcendental.thy*}

text {*In \verb+Transcendental.thy+, the assumptions of the next two lemmas are
$x > 0$ and $y > 0$, while large inequalities are sufficient, with the same proof.*}

lemma powr_divide: "0 \<le> x \<Longrightarrow> 0 \<le> y \<Longrightarrow> (x / y) powr a = (x powr a) / (y powr a)"
  for a b x :: real
  apply (simp add: divide_inverse positive_imp_inverse_positive powr_mult)
  apply (simp add: powr_def exp_minus [symmetric] exp_add [symmetric] ln_inverse)
  done

lemma powr_mult_base: "0 \<le> x \<Longrightarrow>x * x powr y = x powr (1 + y)"
  for x :: real
  by (auto simp: powr_add)


subsection {*Limits*}

text {*The next lemmas are not very natural, but I needed them several times*}

lemma tendsto_shift_1_over_n:
  fixes f::"nat \<Rightarrow> real"
  assumes "(\<lambda>n. f n / n) \<longlonglongrightarrow> l"
  shows "(\<lambda>n. f (n+k) / n) \<longlonglongrightarrow> l"
proof -
  have "(1+k*(1/n))* (f(n+k)/(n+k)) = f(n+k)/n" if "n>0" for n using that by (auto simp add: divide_simps)
  with eventually_mono[OF eventually_gt_at_top[of "0::nat"] this]
  have "eventually (\<lambda>n.(1+k*(1/n))* (f(n+k)/(n+k)) = f(n+k)/n) sequentially"
    by auto
  moreover have "(\<lambda>n. (1+k*(1/n))* (f(n+k)/(n+k))) \<longlonglongrightarrow> (1+real k*0) * l"
    apply (rule tendsto_mult)
    apply (rule tendsto_add, simp, rule tendsto_mult, simp, simp add: lim_1_over_n)
    apply (rule LIMSEQ_ignore_initial_segment[OF assms, of k])
    done
  ultimately show ?thesis using Lim_transform_eventually by auto
qed

lemma tendsto_shift_1_over_n':
  fixes f::"nat \<Rightarrow> real"
  assumes "(\<lambda>n. f n / n) \<longlonglongrightarrow> l"
  shows "(\<lambda>n. f (n-k) / n) \<longlonglongrightarrow> l"
proof -
  have "(1-k*(1/(n+k)))* (f n/ n) = f n/(n+k)" if "n>0" for n using that by (auto simp add: divide_simps)
  with eventually_mono[OF eventually_gt_at_top[of "0::nat"] this]
  have "eventually (\<lambda>n. (1-k*(1/(n+k)))* (f n/ n) = f n/(n+k)) sequentially"
    by auto
  moreover have "(\<lambda>n. (1-k*(1/(n+k)))* (f n/ n)) \<longlonglongrightarrow> (1-real k*0) * l"
    apply (rule tendsto_mult)
    apply (rule tendsto_diff, simp, rule tendsto_mult, simp, rule LIMSEQ_ignore_initial_segment[OF lim_1_over_n, of k])
    apply (simp add: assms)
    done
  ultimately have "(\<lambda>n. f n / (n+k)) \<longlonglongrightarrow> l" using Lim_transform_eventually by auto
  then have a: "(\<lambda>n. f(n-k)/(n-k+k)) \<longlonglongrightarrow> l" using seq_offset_neg by auto

  have "f(n-k)/(n-k+k) = f(n-k)/n" if "n>k" for n
    using that by auto
  with eventually_mono[OF eventually_gt_at_top[of k] this]
  have "eventually (\<lambda>n. f(n-k)/(n-k+k) = f(n-k)/n) sequentially"
    by auto
  with Lim_transform_eventually[OF this a]
  show ?thesis by auto
qed

subsection {*Topology-Euclidean-Space*}

lemma Inf_as_limit:
  fixes A::"'a::{linorder_topology, first_countable_topology, complete_linorder} set"
  assumes "A \<noteq> {}"
  shows "\<exists>u. (\<forall>n. u n \<in> A) \<and> u \<longlonglongrightarrow> Inf A"
proof (cases "Inf A \<in> A")
  case True
  show ?thesis
    by (rule exI[of _ "\<lambda>n. Inf A"], auto simp add: True)
next
  case False
  obtain y where "y \<in> A" using assms by auto
  then have "Inf A < y" using False Inf_lower less_le by auto
  obtain F :: "nat \<Rightarrow> 'a set" where F: "\<And>i. open (F i)" "\<And>i. Inf A \<in> F i"
                                       "\<And>u. (\<forall>n. u n \<in> F n) \<Longrightarrow> u \<longlonglongrightarrow> Inf A"
    by (metis first_countable_topology_class.countable_basis)
  define u where "u = (\<lambda>n. SOME z. z \<in> F n \<and> z \<in> A)"
  have "\<exists>z. z \<in> U \<and> z \<in> A" if "Inf A \<in> U" "open U" for U
  proof -
    obtain b where "b > Inf A" "{Inf A ..<b} \<subseteq> U"
      using open_right[OF `open U` `Inf A \<in> U` `Inf A < y`] by auto
    obtain z where "z < b" "z \<in> A"
      using `Inf A < b` Inf_less_iff by auto
    then have "z \<in> {Inf A ..<b}"
      by (simp add: Inf_lower)
    then show ?thesis using `z \<in> A` `{Inf A ..<b} \<subseteq> U` by auto
  qed
  then have *: "u n \<in> F n \<and> u n \<in> A" for n
    using `Inf A \<in> F n` `open (F n)` unfolding u_def by (metis (no_types, lifting) someI_ex)
  then have "u \<longlonglongrightarrow> Inf A" using F(3) by simp
  then show ?thesis using * by auto
qed

text {*A (more usable) variation around \verb+continuous_on_closure_sequentially+. The assumption
that the spaces are metric spaces is definitely too strong, but sufficient for most applications.*}

lemma continuous_on_closure_sequentially':
  fixes f::"'a::metric_space \<Rightarrow> 'b::metric_space"
  assumes "continuous_on (closure C) f"
          "\<And>(n::nat). u n \<in> C"
          "u \<longlonglongrightarrow> l"
  shows "(\<lambda>n. f (u n)) \<longlonglongrightarrow> f l"
proof -
  have "l \<in> closure C" unfolding closure_sequential using assms by auto
  then show ?thesis
    using `continuous_on (closure C) f` unfolding comp_def continuous_on_closure_sequentially
    using assms by auto
qed


subsection {*Convexity*}

lemma convex_on_mean_ineq:
  fixes f::"real \<Rightarrow> real"
  assumes "convex_on A f" "x \<in> A" "y \<in> A"
  shows "f ((x+y)/2) \<le> (f x + f y) / 2"
using convex_onD[OF assms(1), of "1/2" x y] using assms by (auto simp add: divide_simps)

lemma convex_on_closure:
  assumes "convex (C::'a::real_normed_vector set)"
          "convex_on C f"
          "continuous_on (closure C) f"
  shows "convex_on (closure C) f"
proof (rule convex_onI)
  fix x y::'a and t::real
  assume "x \<in> closure C" "y \<in> closure C" "0 < t" "t < 1"
  obtain u v::"nat \<Rightarrow> 'a" where *: "\<And>n. u n \<in> C" "u \<longlonglongrightarrow> x"
                                   "\<And>n. v n \<in> C" "v \<longlonglongrightarrow> y"
    using `x \<in> closure C` `y \<in> closure C` unfolding closure_sequential by blast
  define w where "w = (\<lambda>n. (1-t) *\<^sub>R (u n) + t *\<^sub>R (v n))"
  have "w n \<in> C" for n
    using `0 < t` `t< 1` convexD[OF `convex C` *(1)[of n] *(3)[of n]] unfolding w_def by auto
  have "w \<longlonglongrightarrow> ((1-t) *\<^sub>R x + t *\<^sub>R y)"
    unfolding w_def using *(2) *(4) by (auto intro!: tendsto_intros)

  have *: "f(w n) \<le> (1-t) * f(u n) + t * f (v n)" for n
    using *(1) *(3) `convex_on C f` `0<t` `t<1` less_imp_le unfolding w_def
    convex_on_alt[OF assms(1)] by (simp add: add.commute)
  have i: "(\<lambda>n. f (w n)) \<longlonglongrightarrow> f ((1-t) *\<^sub>R x + t *\<^sub>R y)"
    by (rule continuous_on_closure_sequentially'[OF assms(3) `\<And>n. w n \<in> C` `w \<longlonglongrightarrow> ((1-t) *\<^sub>R x + t *\<^sub>R y)`])
  have ii: "(\<lambda>n. (1-t) * f(u n) + t * f (v n)) \<longlonglongrightarrow> (1-t) * f x + t * f y"
    apply (auto intro!: tendsto_intros)
    apply (rule continuous_on_closure_sequentially'[OF assms(3) `\<And>n. u n \<in> C` `u \<longlonglongrightarrow> x`])
    apply (rule continuous_on_closure_sequentially'[OF assms(3) `\<And>n. v n \<in> C` `v \<longlonglongrightarrow> y`])
    done
  show "f ((1 - t) *\<^sub>R x + t *\<^sub>R y) \<le> (1 - t) * f x + t * f y"
    apply (rule LIMSEQ_le[OF i ii]) using * by auto
qed

lemma convex_on_norm:
  "convex_on UNIV (\<lambda>(x::'a::real_normed_vector). norm x)"
using convex_on_dist[of UNIV "0::'a"] by auto

lemma continuous_abs_powr [continuous_intros]:
  assumes "p > 0"
  shows "continuous_on UNIV (\<lambda>(x::real). \<bar>x\<bar> powr p)"
apply (rule continuous_on_powr') using assms by (auto intro: continuous_intros)

lemma continuous_mult_sgn [continuous_intros]:
  fixes f::"real \<Rightarrow> real"
  assumes "continuous_on UNIV f" "f 0 = 0"
  shows "continuous_on UNIV (\<lambda>x. sgn x * f x)"
proof -
  have *: "continuous_on {0..} (\<lambda>x. sgn x * f x)"
    apply (subst continuous_on_cong[of "{0..}" "{0..}" _ f], auto simp add: sgn_real_def assms(2))
    by (rule continuous_on_subset[OF assms(1)], auto)
  have **: "continuous_on {..0} (\<lambda>x. sgn x * f x)"
    apply (subst continuous_on_cong[of "{..0}" "{..0}" _ "\<lambda>x. -f x"], auto simp add: sgn_real_def assms(2))
    by (rule continuous_on_subset[of UNIV], auto simp add: assms intro!: continuous_intros)
  show ?thesis
    using continuous_on_closed_Un[OF _ _ * **] apply (auto intro: continuous_intros)
    using continuous_on_subset by fastforce
qed

lemma DERIV_abs_powr [derivative_intros]:
  assumes "p > (1::real)"
  shows "DERIV (\<lambda>x. \<bar>x\<bar> powr p) x :> p * sgn x * \<bar>x\<bar> powr (p - 1)"
proof -
  consider "x = 0" | "x>0" | "x < 0" by linarith
  then show ?thesis
  proof (cases)
    case 1
    have "continuous_on UNIV (\<lambda>x. sgn x * \<bar>x\<bar> powr (p - 1))"
      by (auto simp add: assms intro!:continuous_intros)
    then have "(\<lambda>h. sgn h * \<bar>h\<bar> powr (p-1)) \<midarrow>0\<rightarrow> (\<lambda>h. sgn h * \<bar>h\<bar> powr (p-1)) 0"
      using continuous_on_def by blast
    moreover have "\<bar>h\<bar> powr p / h = sgn h * \<bar>h\<bar> powr (p-1)" for h
    proof -
      have "\<bar>h\<bar> powr p / h = sgn h * \<bar>h\<bar> powr p / \<bar>h\<bar>"
        by (auto simp add: algebra_simps divide_simps sgn_real_def)
      also have "... = sgn h * \<bar>h\<bar> powr (p-1)"
        using assms apply (cases "h=0") apply (auto)
        by (metis abs_ge_zero powr_divide2 powr_one_gt_zero_iff times_divide_eq_right)
      finally show ?thesis by simp
    qed
    ultimately have "(\<lambda>h. \<bar>h\<bar> powr p / h) \<midarrow>0\<rightarrow> 0" by auto
    then show ?thesis unfolding DERIV_def by (auto simp add: `x=0`)
  next
    case 2
    have *: "\<forall>\<^sub>F y in nhds x. \<bar>y\<bar> powr p = y powr p"
      unfolding eventually_nhds apply (rule exI[of _ "{0<..}"]) using `x > 0` by auto
    show ?thesis
      apply (subst DERIV_cong_ev[of _ x _ "(\<lambda>x. x powr p)" _ "p * x powr (p-1)"])
      using `x > 0` by (auto simp add: * has_real_derivative_powr)
  next
    case 3
    have *: "\<forall>\<^sub>F y in nhds x. \<bar>y\<bar> powr p = (-y) powr p"
      unfolding eventually_nhds apply (rule exI[of _ "{..<0}"]) using `x < 0` by auto
    show ?thesis
      apply (subst DERIV_cong_ev[of _ x _ "(\<lambda>x. (-x) powr p)" _ "p * (- x) powr (p - real 1) * - 1"])
      using `x < 0` apply (simp, simp add: *, simp)
      apply (rule DERIV_fun_powr[of "\<lambda>y. -y" "-1" "x" p]) using `x < 0` by (auto simp add: derivative_intros)
  qed
qed

lemma convex_abs_powr:
  assumes "p \<ge> 1"
  shows "convex_on UNIV (\<lambda>x::real. \<bar>x\<bar> powr p)"
proof (cases "p=1")
  case True
  have "convex_on UNIV (\<lambda>x::real. norm x)"
    by (rule convex_on_norm)
  moreover have "\<bar>x\<bar> powr p = norm x" for x using True by auto
  ultimately show ?thesis by simp
next
  case False
  then have "p > 1" using assms by auto
  define g where "g = (\<lambda>x::real. p * sgn x * \<bar>x\<bar> powr (p - 1))"
  have *: "DERIV (\<lambda>x. \<bar>x\<bar> powr p) x :> g x" for x
    unfolding g_def using `p>1` by (auto intro!:derivative_intros)
  have **: "g x \<le> g y" if "x \<le> y" for x y
  proof -
    consider "x \<ge> 0 \<and> y \<ge> 0" | "x \<le> 0 \<and> y \<le> 0" | "x < 0 \<and> y > 0" using `x \<le> y` by linarith
    then show ?thesis
    proof (cases)
      case 1
      then show ?thesis unfolding g_def sgn_real_def using `p>1` `x \<le> y` by (auto simp add: powr_mono2)
    next
      case 2
      then show ?thesis unfolding g_def sgn_real_def using `p>1` `x \<le> y` by (auto simp add: powr_mono2)
    next
      case 3
      then have "g x \<le> 0" "0 \<le> g y" unfolding g_def using `p > 1` by auto
      then show ?thesis by simp
    qed
  qed
  show ?thesis
    apply (rule convex_on_realI[of _ _ g]) using * ** by auto
qed

lemma convex_powr:
  assumes "p \<ge> 1"
  shows "convex_on {0..} (\<lambda>x::real. x powr p)"
proof -
  have "convex_on {0..} (\<lambda>x::real. \<bar>x\<bar> powr p)"
    using convex_abs_powr[OF `p \<ge> 1`] convex_on_subset by auto
  moreover have "\<bar>x\<bar> powr p = x powr p" if "x \<in> {0..}" for x using that by auto
  ultimately show ?thesis by (simp add: convex_on_def)
qed

lemma convex_powr':
  assumes "p > 0" "p \<le> 1"
  shows "convex_on {0..} (\<lambda>x::real. - (x powr p))"
proof -
  have "convex_on {0<..} (\<lambda>x::real. - (x powr p))"
    apply (rule convex_on_realI[of _ _ "\<lambda>x. -p * x powr (p-1)"])
    apply (auto intro!:derivative_intros simp add: has_real_derivative_powr)
    using `p > 0` `p \<le> 1` by (auto simp add: algebra_simps divide_simps powr_mono2')
  moreover have "continuous_on {0..} (\<lambda>x::real. - (x powr p))"
    by (rule continuous_on_minus, rule continuous_on_powr', auto simp add: `p > 0` intro!: continuous_intros)
  moreover have "{(0::real)..} = closure {0<..}" "convex {(0::real)<..}" by auto
  ultimately show ?thesis using convex_on_closure by metis
qed

lemma convex_fx_plus_fy_ineq:
  fixes f::"real \<Rightarrow> real"
  assumes "convex_on {0..} f"
          "x \<ge> 0" "y \<ge> 0" "f 0 = 0"
  shows "f x + f y \<le> f (x+y)"
proof -
  have *: "f a + f b \<le> f (a+b)" if "a \<ge> 0" "b \<ge> a" for a b
  proof (cases "a = 0")
    case False
    then have "a > 0" "b > 0" using `b \<ge> a` `a \<ge> 0` by auto
    have "(f 0 - f a) / (0 - a) \<le> (f 0 - f (a+b))/ (0 - (a+b))"
      apply (rule convex_on_diff[OF `convex_on {0..} f`]) using `a > 0` `b > 0` by auto
    also have "... \<le> (f b - f (a+b)) / (b - (a+b))"
      apply (rule convex_on_diff[OF `convex_on {0..} f`]) using `a > 0` `b > 0` by auto
    finally show ?thesis
      using `a > 0` `b > 0` `f 0 = 0` by (auto simp add: divide_simps algebra_simps)
  qed (simp add: `f 0 = 0`)
  then show ?thesis
    using `x \<ge> 0` `y \<ge> 0` by (metis add.commute le_less not_le)
qed

lemma x_plus_y_p_le_xp_plus_yp:
  fixes p x y::real
  assumes "p > 0" "p \<le> 1" "x \<ge> 0" "y \<ge> 0"
  shows "(x + y) powr p \<le> x powr p + y powr p"
using convex_fx_plus_fy_ineq[OF convex_powr'[OF `p > 0` `p \<le> 1`] `x \<ge> 0` `y \<ge> 0`] by auto




subsection {*Nonnegative-extended-real.thy*}

lemma e2ennreal_mult:
  fixes a b::ereal
  assumes "a \<ge> 0"
  shows "e2ennreal(a * b) = e2ennreal a * e2ennreal b"
by (metis assms e2ennreal_neg eq_onp_same_args ereal_mult_le_0_iff linear times_ennreal.abs_eq)

lemma e2ennreal_mult':
  fixes a b::ereal
  assumes "b \<ge> 0"
  shows "e2ennreal(a * b) = e2ennreal a * e2ennreal b"
using e2ennreal_mult[OF assms, of a] by (simp add: mult.commute)

lemma SUP_real_ennreal:
  assumes "A \<noteq> {}" "bdd_above (f`A)"
  shows "(SUP a:A. ennreal (f a)) = ennreal(SUP a:A. f a)"
apply (rule antisym, simp add: SUP_least assms(2) cSUP_upper ennreal_leI)
by (metis assms(1) ennreal_SUP ennreal_less_top le_less)

lemma ennreal_Inf_cmult:
  assumes "c>(0::real)"
  shows "Inf {ennreal c * x |x. P x} = ennreal c * Inf {x. P x}"
proof -
  have "(\<lambda>x::ennreal. c * x) (Inf {x::ennreal. P x}) = Inf ((\<lambda>x::ennreal. c * x)`{x::ennreal. P x})"
    apply (rule mono_bij_Inf)
    apply (simp add: monoI mult_left_mono)
    apply (rule bij_betw_byWitness[of _ "\<lambda>x. (x::ennreal) / c"], auto simp add: assms)
    apply (metis assms ennreal_lessI ennreal_neq_top mult.commute mult_divide_eq_ennreal not_less_zero)
    apply (metis assms divide_ennreal_def ennreal_less_zero_iff ennreal_neq_top less_irrefl mult.assoc mult.left_commute mult_divide_eq_ennreal)
    done
  then show ?thesis by (simp only: setcompr_eq_image[symmetric])
qed

lemma continuous_on_const_minus_ennreal:
  fixes f :: "'a :: topological_space \<Rightarrow> ennreal"
  shows "continuous_on A f \<Longrightarrow> continuous_on A (\<lambda>x. a - f x)"
  including ennreal.lifting
proof (transfer fixing: A; clarsimp)
  fix f :: "'a \<Rightarrow> ereal" and a :: "ereal" assume "0 \<le> a" "\<forall>x. 0 \<le> f x" and f: "continuous_on A f"
  then show "continuous_on A (\<lambda>x. max 0 (a - f x))"
  proof cases
    assume "\<exists>r. a = ereal r"
    with f show ?thesis
      by (auto simp: continuous_on_def minus_ereal_def ereal_Lim_uminus[symmetric]
              intro!: tendsto_add_ereal_general tendsto_max)
  next
    assume "\<nexists>r. a = ereal r"
    with \<open>0 \<le> a\<close> have "a = \<infinity>"
      by (cases a) auto
    then show ?thesis
      by (simp add: continuous_on_const)
  qed
qed

lemma const_minus_Liminf_ennreal:
  fixes a :: ennreal
  shows "F \<noteq> bot \<Longrightarrow> a - Liminf F f = Limsup F (\<lambda>x. a - f x)"
by (intro Limsup_compose_continuous_antimono[symmetric])
   (auto simp: antimono_def ennreal_mono_minus continuous_on_id continuous_on_const_minus_ennreal)

lemma tendsto_mult_ennreal [tendsto_intros]:
  fixes f g::"_ \<Rightarrow> ennreal"
  assumes "(f \<longlongrightarrow> l) F" "(g \<longlongrightarrow> m) F" "\<not>((l = 0 \<and> m = \<infinity>) \<or> (m = 0 \<and> l = \<infinity>))"
  shows "((\<lambda>x. f x * g x) \<longlongrightarrow> l * m) F"
proof -
  have "((\<lambda>x. enn2ereal(f x) * enn2ereal(g x)) \<longlongrightarrow> enn2ereal l * enn2ereal m) F"
    apply (auto intro!: tendsto_intros simp add: assms)
    by (insert assms le_zero_eq less_eq_ennreal.rep_eq, fastforce)+
  then have "((\<lambda>x. enn2ereal(f x * g x)) \<longlongrightarrow> enn2ereal(l * m)) F"
    using times_ennreal.rep_eq by auto
  then show ?thesis
    by (auto intro!: tendsto_intros)
qed

lemma tendsto_cmult_ennreal [tendsto_intros]:
  fixes c l::ennreal
  assumes "\<not>(c = \<infinity> \<and> l = 0)"
          "(f \<longlongrightarrow> l) F"
  shows "((\<lambda>x. c * f x) \<longlongrightarrow> c * l) F"
by (cases "c = 0", insert assms, auto intro!: tendsto_intros)


subsection {*Indicator.thy*}

text {*There is something weird with \verb+sum_mult_indicator+: it is defined both
in Indicator.thy and BochnerIntegration.thy, with a different meaning. I am surprised
there is no name collision... Here, I am using the version from BochnerIntegration.*}

lemma sum_indicator_eq_card2:
  assumes "finite I"
  shows "(\<Sum>i\<in>I. (indicator (P i) x)::nat) = card {i\<in>I. x \<in> P i}"
using sum_mult_indicator [OF assms, of "\<lambda>y. 1::nat" P "\<lambda>y. x"]
unfolding card_eq_sum by auto


subsection {*sigma-algebra.thy*}

lemma algebra_intersection:
  assumes "algebra \<Omega> A"
          "algebra \<Omega> B"
  shows "algebra \<Omega> (A \<inter> B)"
apply (subst algebra_iff_Un) using assms by (auto simp add: algebra_iff_Un)

lemma sigma_algebra_intersection:
  assumes "sigma_algebra \<Omega> A"
          "sigma_algebra \<Omega> B"
  shows "sigma_algebra \<Omega> (A \<inter> B)"
apply (subst sigma_algebra_iff) using assms by (auto simp add: sigma_algebra_iff algebra_intersection)

text {* The next one is \verb+disjoint_family_Suc+ with inclusions reversed.*}

lemma disjoint_family_Suc2:
  assumes Suc: "\<And>n. A (Suc n) \<subseteq> A n"
  shows "disjoint_family (\<lambda>i. A i - A (Suc i))"
proof -
  have "A (m+n) \<subseteq> A n" for m n
  proof (induct m)
    case 0 show ?case by simp
  next
    case (Suc m) then show ?case
      by (metis Suc_eq_plus1 assms add.commute add.left_commute subset_trans)
  qed
  then have "A m \<subseteq> A n" if "m > n" for m n
    by (metis that add.commute le_add_diff_inverse nat_less_le)
  then show ?thesis
    by (auto simp add: disjoint_family_on_def)
       (metis insert_absorb insert_subset le_SucE le_antisym not_le_imp_less)
qed

text {* the next few lemmas give useful measurability statements*}

text {* The next one is a reformulation of \verb+borel_measurable_Max+.*}


subsection {*Measure-Space.thy *}

lemma emeasure_union_inter:
  assumes "A \<in> sets M" "B \<in> sets M"
  shows "emeasure M A + emeasure M B = emeasure M (A \<union> B) + emeasure M (A \<inter> B)"
proof -
  have "A = (A-B) \<union> (A \<inter> B)" by auto
  then have 1: "emeasure M A = emeasure M (A-B) + emeasure M (A \<inter> B)"
    by (metis Diff_Diff_Int Diff_disjoint assms(1) assms(2) plus_emeasure sets.Diff)

  have "A \<union> B = (A-B) \<union> B" by auto
  then have 2: "emeasure M (A \<union> B) = emeasure M (A-B) + emeasure M B"
    by (metis Diff_disjoint Int_commute assms(1) assms(2) plus_emeasure sets.Diff)

  show ?thesis using 1 2 by (metis add.assoc add.commute)
qed

lemma AE_equal_sum:
  assumes "\<And>i. AE x in M. f i x = g i x"
  shows "AE x in M. (\<Sum>i\<in>I. f i x) = (\<Sum>i\<in>I. g i x)"
proof (cases)
  assume "finite I"
  have "\<exists>A. A \<in> null_sets M \<and> (\<forall>x\<in> (space M - A). f i x = g i x)" for i
    using assms(1)[of i] by (metis (mono_tags, lifting) AE_E3)
  then obtain A where A: "\<And>i. A i \<in> null_sets M \<and> (\<forall>x\<in> (space M -A i). f i x = g i x)"
    by metis
  define B where "B = (\<Union>i\<in>I. A i)"
  have "B \<in> null_sets M" using `finite I` A B_def by blast
  then have "AE x in M. x \<in> space M - B" by (simp add: AE_not_in)
  moreover
  {
    fix x assume "x \<in> space M - B"
    then have "\<And>i. i \<in> I \<Longrightarrow> f i x = g i x" unfolding B_def using A by auto
    then have "(\<Sum>i\<in>I. f i x) = (\<Sum>i\<in>I. g i x)" by auto
  }
  ultimately show ?thesis by auto
qed (simp)

lemma emeasure_pos_unionE:
  assumes "\<And> (N::nat). A N \<in> sets M"
          "emeasure M (\<Union>N. A N) > 0"
  shows "\<exists>N. emeasure M (A N) > 0"
proof (rule ccontr)
  assume "\<not>(\<exists>N. emeasure M (A N) > 0)"
  then have "\<And>N. A N \<in> null_sets M"
    using assms(1) by auto
  then have "(\<Union>N. A N) \<in> null_sets M" by auto
  then show False using assms(2) by auto
qed

lemma (in prob_space) emeasure_intersection:
  fixes e::"nat \<Rightarrow> real"
  assumes [measurable]: "\<And>n. U n \<in> sets M"
      and [simp]: "\<And>n. 0 \<le> e n" "summable e"
      and ge: "\<And>n. emeasure M (U n) \<ge> 1 - (e n)"
  shows "emeasure M (\<Inter>n. U n) \<ge> 1 - (\<Sum>n. e n)"
proof -
  define V where "V = (\<lambda>n. space M - (U n))"
  have [measurable]: "V n \<in> sets M" for n
    unfolding V_def by auto
  have *: "emeasure M (V n) \<le> e n" for n
    unfolding V_def using ge[of n] by (simp add: emeasure_eq_measure prob_compl ennreal_leI)
  have "emeasure M (\<Union>n. V n) \<le> (\<Sum>n. emeasure M (V n))"
    by (rule emeasure_subadditive_countably, auto)
  also have "... \<le> (\<Sum>n. ennreal (e n))"
    using * by (intro suminf_le) auto
  also have "... = ennreal (\<Sum>n. e n)"
    by (intro suminf_ennreal_eq) auto
  finally have "emeasure M (\<Union>n. V n) \<le> suminf e" by simp
  then have "1 - suminf e \<le> emeasure M (space M - (\<Union>n. V n))"
    by (simp add: emeasure_eq_measure prob_compl suminf_nonneg)
  also have "... \<le> emeasure M (\<Inter>n. U n)"
    by (rule emeasure_mono) (auto simp: V_def)
  finally show ?thesis by simp
qed

lemma null_sym_diff_transitive:
  assumes "A \<Delta> B \<in> null_sets M" "B \<Delta> C \<in> null_sets M"
      and [measurable]: "A \<in> sets M" "C \<in> sets M"
  shows "A \<Delta> C \<in> null_sets M"
proof -
  have "A \<Delta> B \<union> B \<Delta> C \<in> null_sets M" using assms(1) assms(2) by auto
  moreover have "A \<Delta> C \<subseteq> A \<Delta> B \<union> B \<Delta> C" by auto
  ultimately show ?thesis by (meson null_sets_subset assms(3) assms(4) sets.Diff sets.Un)
qed

lemma Delta_null_of_null_is_null:
  assumes "B \<in> sets M" "A \<Delta> B \<in> null_sets M" "A \<in> null_sets M"
  shows "B \<in> null_sets M"
proof -
  have "B \<subseteq> A \<union> (A \<Delta> B)" by auto
  then show ?thesis using assms by (meson null_sets.Un null_sets_subset)
qed

lemma Delta_null_same_emeasure:
  assumes "A \<Delta> B \<in> null_sets M" and [measurable]: "A \<in> sets M" "B \<in> sets M"
  shows "emeasure M A = emeasure M B"
proof -
  have "A = (A \<inter> B) \<union> (A-B)" by blast
  moreover have "A-B \<in> null_sets M" using assms null_sets_subset by blast
  ultimately have a: "emeasure M A = emeasure M (A \<inter> B)" using emeasure_Un_null_set by (metis assms(2) assms(3) sets.Int)

  have "B = (A \<inter> B) \<union> (B-A)" by blast
  moreover have "B-A \<in> null_sets M" using assms null_sets_subset by blast
  ultimately have "emeasure M B = emeasure M (A \<inter> B)" using emeasure_Un_null_set by (metis assms(2) assms(3) sets.Int)
  then show ?thesis using a by auto
qed

lemma AE_upper_bound_inf_ereal:
  fixes F G::"'a \<Rightarrow> ereal"
  assumes "\<And>e. (e::real) > 0 \<Longrightarrow> AE x in M. F x \<le> G x + e"
  shows "AE x in M. F x \<le> G x"
proof -
  have "AE x in M. \<forall>n::nat. F x \<le> G x + ereal (1 / Suc n)"
    using assms by (auto simp: AE_all_countable)
  then show ?thesis
  proof (eventually_elim)
    fix x assume x: "\<forall>n::nat. F x \<le> G x + ereal (1 / Suc n)"
    show "F x \<le> G x"
    proof (intro ereal_le_epsilon2[of _ "G x"] allI impI)
      fix e :: real assume "0 < e"
      then obtain n where n: "1 / Suc n < e"
        by (blast elim: nat_approx_posE)
      have "F x \<le> G x + 1 / Suc n"
        using x by simp
      also have "\<dots> \<le> G x + e"
        using n by (intro add_mono ennreal_leI) auto
      finally show "F x \<le> G x + ereal e" .
    qed
  qed
qed

subsection {*Nonnegative-Lebesgue-Integration.thy*}

text{* The next lemma is a variant of \verb+nn_integral_density+,
with the density on the right instead of the left, as seems more common. *}

lemma nn_integral_densityR:
  assumes [measurable]: "f \<in> borel_measurable F" "g \<in> borel_measurable F" and
          "AE x in F. g x \<ge> 0"
  shows "(\<integral>\<^sup>+ x. f x * g x \<partial>F) = (\<integral>\<^sup>+ x. f x \<partial>(density F g))"
proof -
  have "(\<integral>\<^sup>+ x. f x * g x \<partial>F) = (\<integral>\<^sup>+ x. g x * f x \<partial>F)" by (simp add: mult.commute)
  also have "... = (\<integral>\<^sup>+ x. f x \<partial>(density F g))"
    by (rule nn_integral_density[symmetric], simp_all add: assms)
  finally show ?thesis by simp
qed

lemma not_AE_zero_int_ennreal_E:
  fixes f::"'a \<Rightarrow> ennreal"
  assumes "(\<integral>\<^sup>+x. f x \<partial>M) > 0"
      and [measurable]: "f \<in> borel_measurable M"
  shows "\<exists>A\<in>sets M. \<exists>e::real>0. emeasure M A > 0 \<and> (\<forall>x \<in> A. f x \<ge> e)"
proof (rule not_AE_zero_ennreal_E, auto simp add: assms)
  assume *: "AE x in M. f x = 0"
  have "(\<integral>\<^sup>+x. f x \<partial>M) = (\<integral>\<^sup>+x. 0 \<partial>M)" by (rule nn_integral_cong_AE, simp add: *)
  then have "(\<integral>\<^sup>+x. f x \<partial>M) = 0" by simp
  then show False using assms by simp
qed

lemma (in finite_measure) nn_integral_bounded_eq_bound_then_AE:
  assumes "AE x in M. f x \<le> ennreal c" "(\<integral>\<^sup>+x. f x \<partial>M) = c * emeasure M (space M)"
      and [measurable]: "f \<in> borel_measurable M"
  shows "AE x in M. f x = c"
proof (cases)
  assume "emeasure M (space M) = 0"
  then show ?thesis by (rule emeasure_0_AE)
next
  assume "emeasure M (space M) \<noteq> 0"
  have fin: "AE x in M. f x \<noteq> top" using assms by (auto simp: top_unique)
  define g where "g = (\<lambda>x. c - f x)"
  have [measurable]: "g \<in> borel_measurable M" unfolding g_def by auto
  have "(\<integral>\<^sup>+x. g x \<partial>M) = (\<integral>\<^sup>+x. c \<partial>M) - (\<integral>\<^sup>+x. f x \<partial>M)"
    unfolding g_def by (rule nn_integral_diff, auto simp add: assms ennreal_mult_eq_top_iff)
  also have "\<dots> = 0" using assms(2) by (auto simp: ennreal_mult_eq_top_iff)
  finally have "AE x in M. g x = 0"
    by (subst nn_integral_0_iff_AE[symmetric]) auto
  then have "AE x in M. c \<le> f x" unfolding g_def using fin by (auto simp: ennreal_minus_eq_0)
  then show ?thesis using assms(1) by auto
qed


subsection {*Lebesgue-Measure.thy*}

text{* The next lemma is the same as \verb+lborel_distr_plus+ which is only formulated
on the real line, but on any euclidean space *}

lemma lborel_distr_plus2:
  fixes c :: "'a::euclidean_space"
  shows "distr lborel borel (op + c) = lborel"
by (subst lborel_affine[of 1 c], auto simp: density_1)


end
