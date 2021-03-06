(*  
    Author:      René Thiemann 
                 Akihisa Yamada
                 Jose Divason
    License:     BSD
*)
section \<open>Missing Polynomial\<close>

text \<open>The theory contains some basic results on polynomials which have not been detected in
  the distribution, especially on linear factors and degrees.\<close>

theory Missing_Polynomial
imports 
  "~~/src/HOL/Library/Polynomial_Factorial"
  Missing_Unsorted
begin       

subsection \<open>Basic Properties\<close>

lemma degree_0_id: assumes "degree p = 0"
  shows "[: coeff p 0 :] = p" 
proof -
  have "\<And> x. 0 \<noteq> Suc x" by auto 
  thus ?thesis using assms
  by (metis coeff_pCons_0 degree_pCons_eq_if pCons_cases)
qed

lemma degree0_coeffs: "degree p = 0 \<Longrightarrow>
  \<exists> a. p = [: a :]"
  by (metis degree_pCons_eq_if old.nat.distinct(2) pCons_cases)

lemma degree1_coeffs: "degree p = 1 \<Longrightarrow>
  \<exists> a b. p = [: b, a :] \<and> a \<noteq> 0" 
  by (metis One_nat_def degree_pCons_eq_if nat.inject old.nat.distinct(2) pCons_0_0 pCons_cases)

lemma degree2_coeffs: "degree p = 2 \<Longrightarrow>
  \<exists> a b c. p = [: c, b, a :] \<and> a \<noteq> 0"
  by (metis Suc_1 Suc_neq_Zero degree1_coeffs degree_pCons_eq_if nat.inject pCons_cases)

lemma poly_zero:
  fixes p :: "'a :: comm_ring_1 poly"
  assumes x: "poly p x = 0" shows "p = 0 \<longleftrightarrow> degree p = 0"
proof
  assume degp: "degree p = 0"
  hence "poly p x = coeff p (degree p)" by(subst degree_0_id[OF degp,symmetric], simp)
  hence "coeff p (degree p) = 0" using x by auto
  thus "p = 0" by auto
qed auto

lemma coeff_monom_Suc: "coeff (monom a (Suc d) * p) (Suc i) = coeff (monom a d * p) i"
  by (simp add: monom_Suc)

lemma coeff_sum_monom:
  assumes n: "n \<le> d"
  shows "coeff (\<Sum>i\<le>d. monom (f i) i) n = f n" (is "?l = _")
proof -
  have "?l = (\<Sum>i\<le>d. coeff (monom (f i) i) n)" (is "_ = sum ?cmf _")
    using coeff_sum.
  also have "{..d} = insert n ({..d}-{n})" using n by auto
    hence "sum ?cmf {..d} = sum ?cmf ..." by auto
  also have "... = sum ?cmf ({..d}-{n}) + ?cmf n" by (subst sum.insert,auto)
  also have "sum ?cmf ({..d}-{n}) = 0" by (subst sum.neutral, auto)
  finally show ?thesis by simp
qed

lemma linear_poly_root: "(a :: 'a :: comm_ring_1) \<in> set as \<Longrightarrow> poly (\<Prod> a \<leftarrow> as. [: - a, 1:]) a = 0"
proof (induct as)
  case (Cons b as)
  show ?case
  proof (cases "a = b")
    case False
    with Cons have "a \<in> set as" by auto
    from Cons(1)[OF this] show ?thesis by simp
  qed simp
qed simp

lemma degree_lcoeff_sum: assumes deg: "degree (f q) = n"
  and fin: "finite S" and q: "q \<in> S" and degle: "\<And> p . p \<in> S - {q} \<Longrightarrow> degree (f p) < n"
  and cong: "coeff (f q) n = c"
  shows "degree (sum f S) = n \<and> coeff (sum f S) n = c"
proof (cases "S = {q}")
  case True
  thus ?thesis using deg cong by simp
next
  case False
  with q obtain p where "p \<in> S - {q}" by auto
  from degle[OF this] have n: "n > 0" by auto
  have "degree (sum f S) = degree (f q + sum f (S - {q}))"
    unfolding sum.remove[OF fin q] ..
  also have "\<dots> = degree (f q)"
  proof (rule degree_add_eq_left)
    have "degree (sum f (S - {q})) \<le> n - 1"
    proof (rule degree_sum_le)
      fix p
      show "p \<in> S - {q} \<Longrightarrow> degree (f p) \<le> n - 1"
        using degle[of p] by auto
    qed (insert fin, auto)
    also have "\<dots> < n" using n by simp
    finally show "degree (sum f (S - {q})) < degree (f q)" unfolding deg .
  qed
  finally show ?thesis unfolding deg[symmetric] cong[symmetric]
  proof (rule conjI)
    have id: "(\<Sum>x\<in>S - {q}. coeff (f x) (degree (f q))) = 0"
      by (rule sum.neutral, rule ballI, rule coeff_eq_0[OF degle[folded deg]])
    show "coeff (sum f S) (degree (f q)) = coeff (f q) (degree (f q))"
      unfolding coeff_sum
      by (subst sum.remove[OF _ q], unfold id, insert fin, auto)
  qed
qed

lemma degree_sum_list_le: "(\<And> p . p \<in> set ps \<Longrightarrow> degree p \<le> n)
  \<Longrightarrow> degree (sum_list ps) \<le> n"
proof (induct ps)
  case (Cons p ps)
  hence "degree (sum_list ps) \<le> n" "degree p \<le> n" by auto
  thus ?case unfolding sum_list.Cons by (metis degree_add_le)
qed simp

lemma degree_prod_list_le: "degree (prod_list ps) \<le> sum_list (map degree ps)"
proof (induct ps)
  case (Cons p ps)
  show ?case unfolding prod_list.Cons
    by (rule order.trans[OF degree_mult_le], insert Cons, auto)
qed simp

lemma smult_sum: "smult (\<Sum>i \<in> S. f i) p = (\<Sum>i \<in> S. smult (f i) p)"
  by (induct S rule: infinite_finite_induct, auto simp: smult_add_left)


lemma range_coeff: "range (coeff p) = insert 0 (set (coeffs p))" 
  by (metis nth_default_coeffs_eq range_nth_default)

lemma smult_power: "(smult a p) ^ n = smult (a ^ n) (p ^ n)"
  by (induct n, auto simp: field_simps)

lemma poly_sum_list: "poly (sum_list ps) x = sum_list (map (\<lambda> p. poly p x) ps)"
  by (induct ps, auto)

lemma poly_prod_list: "poly (prod_list ps) x = prod_list (map (\<lambda> p. poly p x) ps)"
  by (induct ps, auto)

lemma sum_list_neutral: "(\<And> x. x \<in> set xs \<Longrightarrow> x = 0) \<Longrightarrow> sum_list xs = 0"
  by (induct xs, auto)

lemma prod_list_neutral: "(\<And> x. x \<in> set xs \<Longrightarrow> x = 1) \<Longrightarrow> prod_list xs = 1"
  by (induct xs, auto)

lemma (in comm_monoid_mult) prod_list_map_remove1:
  "x \<in> set xs \<Longrightarrow> prod_list (map f xs) = f x * prod_list (map f (remove1 x xs))"
  by (induct xs) (auto simp add: ac_simps)

lemma poly_as_sum:
  fixes p :: "'a::comm_semiring_1 poly"
  shows "poly p x = (\<Sum>i\<le>degree p. x ^ i * coeff p i)"
  unfolding poly_altdef by (simp add: ac_simps)

lemma poly_prod_0: "finite ps \<Longrightarrow> poly (prod f ps) x = (0 :: 'a :: field) \<longleftrightarrow> (\<exists> p \<in> ps. poly (f p) x = 0)"
  by (induct ps rule: finite_induct, auto)

lemma coeff_monom_mult:
  shows "coeff (monom a d * p) i =
    (if d \<le> i then a * coeff p (i-d) else 0)" (is "?l = ?r")
proof (cases "d \<le> i")
  case False thus ?thesis unfolding coeff_mult by simp
  next case True
    let ?f = "\<lambda>j. coeff (monom a d) j * coeff p (i - j)"
    have "\<And>j. j \<in> {0..i} - {d} \<Longrightarrow> ?f j = 0" by auto
    hence "0 = (\<Sum>j \<in> {0..i} - {d}. ?f j)" by auto
    also have "... + ?f d = (\<Sum>j \<in> insert d ({0..i} - {d}). ?f j)"
      by(subst sum.insert, auto)
    also have "... = (\<Sum>j \<in> {0..i}. ?f j)" by (subst insert_Diff, insert True, auto)
    also have "... = (\<Sum>j\<le>i. ?f j)" by (rule sum.cong, auto)
    also have "... = ?l" unfolding coeff_mult ..
    finally show ?thesis using True by auto
qed

lemma poly_eqI2:
  assumes "degree p = degree q" and "\<And>i. i \<le> degree p \<Longrightarrow> coeff p i = coeff q i"
  shows "p = q"
  apply(rule poly_eqI) by (metis assms le_degree)

text {*
  A nicer condition for 'a @{type poly} to be @{class ring_char_0} over @{class linordered_field}
*}

instance poly :: ("{ring_char_0,idom}") ring_char_0
proof
  show "inj (of_nat :: nat \<Rightarrow> 'a poly)" unfolding inj_on_def
  proof (intro impI ballI)
    fix x y :: nat
    assume "of_nat x = (of_nat y :: 'a poly)"
    thus "x = y" unfolding of_nat_poly by auto
  qed
qed

text {* A nice extension rule for polynomials. *}
lemma poly_ext[intro]:
  fixes p q :: "'a :: {ring_char_0, idom} poly"
  assumes "\<And>x. poly p x = poly q x" shows "p = q"
  unfolding poly_eq_poly_eq_iff[symmetric]
  using assms by (rule ext)

text {* Copied from non-negative variants. *}
lemma coeff_linear_power_neg[simp]:
  fixes a :: "'a::comm_ring_1"
  shows "coeff ([:a, -1:] ^ n) n = (-1)^n"
apply (induct n, simp_all)
apply (subst coeff_eq_0)
apply (auto intro: le_less_trans degree_power_le)
done

lemma degree_linear_power_neg[simp]:
  fixes a :: "'a::{idom,comm_ring_1}"
  shows "degree ([:a, -1:] ^ n) = n"
apply (rule order_antisym)
apply (rule ord_le_eq_trans [OF degree_power_le], simp)
apply (rule le_degree)
unfolding coeff_linear_power_neg
apply (auto)
done


subsection \<open>Polynomial Composition\<close>

lemmas [simp] = pcompose_pCons

lemma pcompose_eq_0: fixes q :: "'a :: idom poly"
  assumes q: "degree q \<noteq> 0"
  shows "p \<circ>\<^sub>p q = 0 \<longleftrightarrow> p = 0"
proof (induct p)
  case 0
  show ?case by auto
next
  case (pCons a p)
  have id: "(pCons a p) \<circ>\<^sub>p q = [:a:] + q * (p \<circ>\<^sub>p q)" by simp
  show ?case 
  proof (cases "p = 0")
    case True
    show ?thesis unfolding id unfolding True by simp
  next
    case False
    with pCons(2) have "p \<circ>\<^sub>p q \<noteq> 0" by auto
    from degree_mult_eq[OF _ this, of q] q have "degree (q * (p \<circ>\<^sub>p q)) \<noteq> 0" by force
    hence deg: "degree ([:a:] + q * (p \<circ>\<^sub>p q)) \<noteq> 0"
      by (subst degree_add_eq_right, auto)
    show ?thesis unfolding id using False deg by auto
  qed
qed

declare degree_pcompose[simp]

subsection \<open>Monic Polynomials\<close>

abbreviation monic where "monic p \<equiv> coeff p (degree p) = 1"

lemma unit_factor_field [simp]: 
  "unit_factor (x :: 'a :: {field,normalization_semidom}) = x"
  by (cases "is_unit x") (auto simp: is_unit_unit_factor dvd_field_iff)

lemma poly_gcd_monic: 
  fixes p :: "'a :: {field,factorial_ring_gcd} poly"
  assumes "p \<noteq> 0 \<or> q \<noteq> 0"
  shows   "monic (gcd p q)"
proof -
  from assms have "1 = unit_factor (gcd p q)" by (auto simp: unit_factor_gcd)
  also have "\<dots> = [:lead_coeff (gcd p q):]" unfolding unit_factor_poly_def
    by (simp add: monom_0)
  finally show ?thesis by (simp add: one_poly_def lead_coeff_def)
qed

lemma normalize_monic: "monic p \<Longrightarrow> normalize p = p"
  by (simp add: normalize_poly_def lead_coeff_def)

lemma lcoeff_monic_mult: assumes monic: "monic (p :: 'a :: comm_semiring_1 poly)"
  shows "coeff (p * q) (degree p + degree q) = coeff q (degree q)"
proof -
  let ?pqi = "\<lambda> i. coeff p i * coeff q (degree p + degree q - i)" 
  have "coeff (p * q) (degree p + degree q) = 
    (\<Sum>i\<le>degree p + degree q. ?pqi i)"
    unfolding coeff_mult by simp
  also have "\<dots> = ?pqi (degree p) + (sum ?pqi ({.. degree p + degree q} - {degree p}))"
    by (subst sum.remove[of _ "degree p"], auto)
  also have "?pqi (degree p) = coeff q (degree q)" unfolding monic by simp
  also have "(sum ?pqi ({.. degree p + degree q} - {degree p})) = 0"
  proof (rule sum.neutral, intro ballI)
    fix d
    assume d: "d \<in> {.. degree p + degree q} - {degree p}"
    show "?pqi d = 0"
    proof (cases "d < degree p")
      case True
      hence "degree p + degree q - d > degree q" by auto
      hence "coeff q (degree p + degree q - d) = 0" by (rule coeff_eq_0)
      thus ?thesis by simp
    next
      case False
      with d have "d > degree p" by auto
      hence "coeff p d = 0" by (rule coeff_eq_0)
      thus ?thesis by simp
    qed
  qed
  finally show ?thesis by simp
qed

lemma degree_monic_mult: assumes monic: "monic (p :: 'a :: comm_semiring_1 poly)"
  and q: "q \<noteq> 0"
  shows "degree (p * q) = degree p + degree q"
proof -
  have "degree p + degree q \<ge> degree (p * q)" by (rule degree_mult_le)
  also have "degree p + degree q \<le> degree (p * q)"
  proof -
    from q have cq: "coeff q (degree q) \<noteq> 0" by auto
    hence "coeff (p * q) (degree p + degree q) \<noteq> 0" unfolding lcoeff_monic_mult[OF monic] .
    thus "degree (p * q) \<ge> degree p + degree q" by (rule le_degree)
  qed
  finally show ?thesis .
qed

lemma degree_prod_sum_monic: assumes
  S: "finite S"
  and nzd: "0 \<notin> (degree o f) ` S"
  and monic: "(\<And> a . a \<in> S \<Longrightarrow> monic (f a))"
  shows "degree (prod f S) = (sum (degree o f) S) \<and> coeff (prod f S) (sum (degree o f) S) = 1"
proof -
  from S nzd monic 
  have "degree (prod f S) = sum (degree \<circ> f) S 
  \<and> (S \<noteq> {} \<longrightarrow> degree (prod f S) \<noteq> 0 \<and> prod f S \<noteq> 0) \<and> coeff (prod f S) (sum (degree o f) S) = 1"
  proof (induct S rule: finite_induct)
    case (insert a S)
    have IH1: "degree (prod f S) = sum (degree o f) S"
      using insert by auto
    have IH2: "coeff (prod f S) (degree (prod f S)) = 1"
      using insert by auto
    have id: "degree (prod f (insert a S)) = sum (degree \<circ> f) (insert a S)
      \<and> coeff (prod f (insert a S)) (sum (degree o f) (insert a S)) = 1"
    proof (cases "S = {}")
      case False
      with insert have nz: "prod f S \<noteq> 0" by auto
      from insert have monic: "coeff (f a) (degree (f a)) = 1" by auto
      have id: "(degree \<circ> f) a = degree (f a)" by simp
      show ?thesis unfolding prod.insert[OF insert(1-2)] sum.insert[OF insert(1-2)] id
        unfolding degree_monic_mult[OF monic nz] 
        unfolding IH1[symmetric]
        unfolding lcoeff_monic_mult[OF monic] IH2 by simp
    qed (insert insert, auto)
    show ?case using id unfolding sum.insert[OF insert(1-2)] using insert by auto
  qed simp
  thus ?thesis by auto
qed 

lemma degree_prod_monic: 
  assumes "\<And> i. i < n \<Longrightarrow> degree (f i :: 'a :: comm_semiring_1 poly) = 1"
    and "\<And> i. i < n \<Longrightarrow> coeff (f i) 1 = 1"
  shows "degree (prod f {0 ..< n}) = n \<and> coeff (prod f {0 ..< n}) n = 1"
proof -
  from degree_prod_sum_monic[of "{0 ..< n}" f] show ?thesis using assms by force
qed

lemma degree_prod_sum_lt_n: assumes "\<And> i. i < n \<Longrightarrow> degree (f i :: 'a :: comm_semiring_1 poly) \<le> 1"
  and i: "i < n" and fi: "degree (f i) = 0"
  shows "degree (prod f {0 ..< n}) < n"
proof -
  have "degree (prod f {0 ..< n}) \<le> sum (degree o f) {0 ..< n}"
    by (rule degree_prod_sum_le, auto)
  also have "sum (degree o f) {0 ..< n} = (degree o f) i + sum (degree o f) ({0 ..< n} - {i})"
    by (rule sum.remove, insert i, auto)
  also have "(degree o f) i = 0" using fi by simp
  also have "sum (degree o f) ({0 ..< n} - {i}) \<le> sum (\<lambda> _. 1) ({0 ..< n} - {i})"
    by (rule sum_mono, insert assms, auto)
  also have "\<dots> = n - 1" using i by simp
  also have "\<dots> < n" using i by simp
  finally show ?thesis by simp
qed

lemma degree_linear_factors: "degree (\<Prod> a \<leftarrow> as. [: f a, 1:]) = length as"
proof (induct as)
  case (Cons b as) note IH = this
  have id: "(\<Prod>a\<leftarrow>b # as. [:f a, 1:]) = [:f b,1 :] * (\<Prod>a\<leftarrow>as. [:f a, 1:])" by simp
  show ?case unfolding id
    by (subst degree_monic_mult, insert IH, auto)
qed simp

lemma monic_mult:
  fixes p q :: "'a :: idom poly"
  assumes "monic p" "monic q"
  shows "monic (p * q)"
proof -
  from assms have nz: "p \<noteq> 0" "q \<noteq> 0" by auto
  show ?thesis unfolding degree_mult_eq[OF nz] coeff_mult_degree_sum
    using assms by simp
qed

lemma monic_factor:
  fixes p q :: "'a :: idom poly"
  assumes "monic (p * q)" "monic p"
  shows "monic q"
proof -
  from assms have nz: "p \<noteq> 0" "q \<noteq> 0" by auto
  from assms[unfolded degree_mult_eq[OF nz] coeff_mult_degree_sum `monic p`]
  show ?thesis by simp
qed

lemma monic_prod:
  fixes f :: "'a \<Rightarrow> 'b :: idom poly"
  assumes "\<And> a. a \<in> as \<Longrightarrow> monic (f a)"
  shows "monic (prod f as)" using assms
proof (induct as rule: infinite_finite_induct)
  case (insert a as)
  hence id: "prod f (insert a as) = f a * prod f as" 
    and *: "monic (f a)" "monic (prod f as)" by auto
  show ?case unfolding id by (rule monic_mult[OF *])
qed auto

lemma monic_prod_list:
  fixes as :: "'a :: idom poly list"
  assumes "\<And> a. a \<in> set as \<Longrightarrow> monic a"
  shows "monic (prod_list as)" using assms
  by (induct as, auto intro: monic_mult)

lemma monic_power:
  assumes "monic (p :: 'a :: idom poly)"
  shows "monic (p ^ n)"
  by (induct n, insert assms, auto intro: monic_mult)

lemma monic_prod_list_pow: "monic (\<Prod>(x::'a::idom, i)\<leftarrow>xis. [:- x, 1:] ^ Suc i)"
proof (rule monic_prod_list, goal_cases)
  case (1 a)
  then obtain x i where a: "a = [:-x, 1:]^Suc i" by force
  show "monic a" unfolding a
    by (rule monic_power, auto)
qed

lemma monic_degree_0: "monic p \<Longrightarrow> (degree p = 0) = (p = 1)"
  using le_degree poly_eq_iff by force

subsection \<open>Roots\<close>

text \<open>The following proof structure is completely similar to the one
  of @{thm poly_roots_finite}.\<close>

lemma poly_roots_degree:
  fixes p :: "'a::idom poly"
  shows "p \<noteq> 0 \<Longrightarrow> card {x. poly p x = 0} \<le> degree p"
proof (induct n \<equiv> "degree p" arbitrary: p)
  case (0 p)
  then obtain a where "a \<noteq> 0" and "p = [:a:]"
    by (cases p, simp split: if_splits)
  then show ?case by simp
next
  case (Suc n p)
  show ?case
  proof (cases "\<exists>x. poly p x = 0")
    case True
    then obtain a where a: "poly p a = 0" ..
    then have "[:-a, 1:] dvd p" by (simp only: poly_eq_0_iff_dvd)
    then obtain k where k: "p = [:-a, 1:] * k" ..
    with `p \<noteq> 0` have "k \<noteq> 0" by auto
    with k have "degree p = Suc (degree k)"
      by (simp add: degree_mult_eq del: mult_pCons_left)
    with `Suc n = degree p` have "n = degree k" by simp
    from Suc.hyps(1)[OF this `k \<noteq> 0`]
    have le: "card {x. poly k x = 0} \<le> degree k" .
    have "card {x. poly p x = 0} = card {x. poly ([:-a, 1:] * k) x = 0}" unfolding k ..
    also have "{x. poly ([:-a, 1:] * k) x = 0} = insert a {x. poly k x = 0}"
      by auto
    also have "card \<dots> \<le> Suc (card {x. poly k x = 0})" 
      unfolding card_insert_if[OF poly_roots_finite[OF `k \<noteq> 0`]] by simp
    also have "\<dots> \<le> Suc (degree k)" using le by auto
    finally show ?thesis using `degree p = Suc (degree k)` by simp
  qed simp
qed

lemma poly_root_factor: "(poly ([: r, 1:] * q) (k :: 'a :: idom) = 0) = (k = -r \<or> poly q k = 0)" (is ?one)
  "(poly (q * [: r, 1:]) k = 0) = (k = -r \<or> poly q k = 0)" (is ?two)
  "(poly [: r, 1 :] k = 0) = (k = -r)" (is ?three)
proof -
  have [simp]: "r + k = 0 \<Longrightarrow> k = - r" by (simp add: minus_unique)
  show ?one unfolding poly_mult by auto
  show ?two unfolding poly_mult by auto
  show ?three by auto
qed

lemma poly_root_constant: "c \<noteq> 0 \<Longrightarrow> (poly (p * [:c:]) (k :: 'a :: idom) = 0) = (poly p k = 0)"
  unfolding poly_mult by auto


lemma poly_linear_exp_linear_factors_rev: 
  "([:b,1:])^(length (filter (op = b) as)) dvd (\<Prod> (a :: 'a :: comm_ring_1) \<leftarrow> as. [: a, 1:])"
proof (induct as)
  case (Cons a as)
  let ?ls = "length (filter (op = b) (a # as))"
  let ?l = "length (filter (op = b) as)"
  have prod: "(\<Prod> a \<leftarrow> Cons a as. [: a, 1:]) = [: a, 1 :] * (\<Prod> a \<leftarrow> as. [: a, 1:])" by simp
  show ?case
  proof (cases "a = b")
    case False
    hence len: "?ls = ?l" by simp
    show ?thesis unfolding prod len using Cons by (rule dvd_mult)
  next
    case True
    hence len: "[: b, 1 :] ^ ?ls = [: a, 1 :] * [: b, 1 :] ^ ?l" by simp
    show ?thesis unfolding prod len using Cons using dvd_refl mult_dvd_mono by blast
  qed
qed simp

lemma order_max: assumes dvd: "[: -a, 1 :] ^ k dvd p" and p: "p \<noteq> 0"
  shows "k \<le> order a p"
proof (rule ccontr)
  assume "\<not> ?thesis"
  hence "\<exists> j. k = Suc (order a p + j)" by arith
  then obtain j where k: "k = Suc (order a p + j)" by auto
  have "[: -a, 1 :] ^ Suc (order a p) dvd p"
    by (rule power_le_dvd[OF dvd[unfolded k]], simp)
  with order_2[OF p, of a] show False by blast
qed


subsection \<open>Divisibility\<close>

context
  assumes "SORT_CONSTRAINT('a :: idom)"
begin
lemma poly_linear_linear_factor: assumes 
  dvd: "[:b,1:] dvd (\<Prod> (a :: 'a) \<leftarrow> as. [: a, 1:])"
  shows "b \<in> set as"
proof -
  let ?p = "\<lambda> as. (\<Prod> a \<leftarrow> as. [: a, 1:])"
  let ?b = "[:b,1:]"
  from assms[unfolded dvd_def] obtain p where id: "?p as = ?b * p" ..
  from arg_cong[OF id, of "\<lambda> p. poly p (-b)"]
  have "poly (?p as) (-b) = 0" by simp
  thus ?thesis
  proof (induct as)
    case (Cons a as)
    have "?p (a # as) = [:a,1:] * ?p as" by simp
    from Cons(2)[unfolded this] have "poly (?p as) (-b) = 0 \<or> (a - b) = 0" by simp
    with Cons(1) show ?case by auto
  qed simp
qed

lemma poly_linear_exp_linear_factors: 
  assumes dvd: "([:b,1:])^n dvd (\<Prod> (a :: 'a) \<leftarrow> as. [: a, 1:])"
  shows "length (filter (op = b) as) \<ge> n"
proof -
  let ?p = "\<lambda> as. (\<Prod> a \<leftarrow> as. [: a, 1:])"
  let ?b = "[:b,1:]"
  from dvd show ?thesis
  proof (induct n arbitrary: as)
    case (Suc n as)
    have bs: "?b ^ Suc n = ?b * ?b ^ n" by simp
    from poly_linear_linear_factor[OF dvd_mult_left[OF Suc(2)[unfolded bs]], 
      unfolded in_set_conv_decomp]
    obtain as1 as2 where as: "as = as1 @ b # as2" by auto
    have "?p as = [:b,1:] * ?p (as1 @ as2)" unfolding as
    proof (induct as1)
      case (Cons a as1)
      have "?p (a # as1 @ b # as2) = [:a,1:] * ?p (as1 @ b # as2)" by simp
      also have "?p (as1 @ b # as2) = [:b,1:] * ?p (as1 @ as2)" unfolding Cons by simp
      also have "[:a,1:] * \<dots> = [:b,1:] * ([:a,1:] * ?p (as1 @ as2))" 
        by (metis (no_types, lifting) mult.left_commute)
      finally show ?case by simp
    qed simp
    from Suc(2)[unfolded bs this dvd_mult_cancel_left]
    have "?b ^ n dvd ?p (as1 @ as2)" by simp
    from Suc(1)[OF this] show ?case unfolding as by simp
  qed simp    
qed
end

lemma const_poly_dvd: "([:a:] dvd [:b:]) = (a dvd b)"
proof
  assume "a dvd b"
  then obtain c where "b = a * c" unfolding dvd_def by auto
  hence "[:b:] = [:a:] * [: c:]" by (auto simp: ac_simps)
  thus "[:a:] dvd [:b:]" unfolding dvd_def by blast
next
  assume "[:a:] dvd [:b:]"
  then obtain pc where "[:b:] =  [:a:] * pc" unfolding dvd_def by blast
  from arg_cong[OF this, of "\<lambda> p. coeff p 0", unfolded coeff_mult]
  have "b = a * coeff pc 0" by auto
  thus "a dvd b" unfolding dvd_def by blast
qed

lemma const_poly_dvd_1: "([:a:] dvd 1) = (a dvd 1)"
  unfolding one_poly_def const_poly_dvd ..

lemma poly_dvd_1: "(p dvd (1 :: 'a :: idom poly)) = (degree p = 0 \<and> coeff p 0 dvd 1)"
proof (cases "degree p = 0")
  case False
  with divides_degree[of p 1] show ?thesis by auto
next
  case True
  from degree0_coeffs[OF this] obtain a where p: "p = [:a:]" by auto
  show ?thesis unfolding p const_poly_dvd_1 by auto
qed

definition irreducible :: "'a :: idom poly \<Rightarrow> bool" where
  "irreducible p = (degree p \<noteq> 0 \<and> (\<forall> q. degree q \<noteq> 0 \<longrightarrow> degree q < degree p \<longrightarrow> \<not> q dvd p))"

lemma irreducibleI: assumes 
  "degree p \<noteq> 0" "\<And> q. degree q \<noteq> 0 \<Longrightarrow> degree q < degree p \<Longrightarrow> \<not> q dvd p"
  shows "irreducible p" using assms unfolding irreducible_def by auto

lemma irreducibleI2: assumes 
  deg: "degree p \<noteq> 0" and ndvd: "\<And> q. degree q \<ge> 1 \<Longrightarrow> degree q \<le> degree p div 2 \<Longrightarrow> \<not> q dvd p"
  shows "irreducible p"
proof (rule ccontr)
  assume "\<not> ?thesis"
  from this[unfolded irreducible_def] deg obtain q where dq: "degree q \<noteq> 0" "degree q < degree p"
    and dvd: "q dvd p" by auto
  from dvd obtain r where p: "p = q * r" unfolding dvd_def by auto
  from deg have p0: "p \<noteq> 0" by auto
  with p have "q \<noteq> 0" "r \<noteq> 0" by auto
  from degree_mult_eq[OF this] p have dp: "degree p = degree q + degree r" by simp
  show False
  proof (cases "degree q \<le> degree p div 2")
    case True
    from ndvd[OF _ True] dq dvd show False by auto
  next
    case False
    with dp have dr: "degree r \<le> degree p div 2" by auto
    from p have dvd: "r dvd p" by auto
    from ndvd[OF _ dr] dvd dp dq show False by auto
  qed
qed
    

lemma irreducibleD: assumes "irreducible p"
  shows "degree p \<noteq> 0" "\<And> q. degree q \<noteq> 0 \<Longrightarrow> degree q < degree p \<Longrightarrow> \<not> q dvd p"
  using assms unfolding irreducible_def by auto

lemma irreducible_factor: assumes
  "degree p \<noteq> 0" 
  shows "\<exists> q r. irreducible q \<and> p = q * r \<and> degree r < degree p" using assms
proof (induct "degree p" arbitrary: p rule: less_induct)
  case (less p)
  show ?case
  proof (cases "irreducible p")
    case False
    with less(2) obtain q where q: "degree q < degree p" "degree q \<noteq> 0"  and dvd: "q dvd p"
      unfolding irreducible_def by auto
    from dvd obtain r where p: "p = q * r" unfolding dvd_def by auto
    from less(1)[OF q] obtain s t where IH: "irreducible s" "q = s * t" by auto
    from p have p: "p = s * (t * r)" unfolding IH by (simp add: ac_simps)
    from less(2) have "p \<noteq> 0" by auto
    hence "degree p = degree s + (degree (t * r))" unfolding p 
      by (subst degree_mult_eq, insert p, auto)
    with irreducibleD[OF IH(1)] have "degree p > degree (t * r)" by auto
    with p IH show ?thesis by auto
  next
    case True
    show ?thesis
      by (rule exI[of _ p], rule exI[of _ 1], insert True less(2), auto)
  qed 
qed

lemma irreducible_smultI: 
  "irreducible (smult c p) \<Longrightarrow> c \<noteq> 0 \<Longrightarrow> irreducible p" 
  using dvd_smult[of _ p c] unfolding irreducible_def by auto

lemma irreducible_smult[simp]: fixes c :: "'a :: field" assumes "c \<noteq> 0"
  shows "irreducible (smult c p) = irreducible p" using `c \<noteq> 0`
  unfolding irreducible_def by (auto simp: dvd_smult_iff[OF `c \<noteq> 0`])

lemma irreducible_monic_factor: fixes p :: "'a :: field poly" 
  assumes "degree p \<noteq> 0" 
  shows "\<exists> q r. irreducible q \<and> p = q * r \<and> monic q"
proof -
  from irreducible_factor[OF assms]
  obtain q r where q: "irreducible q" and p: "p = q * r" by auto
  define c where "c = coeff q (degree q)"
  from q have c: "c \<noteq> 0" unfolding c_def irreducible_def by auto
  show ?thesis
    by (rule exI[of _ "smult (1/c) q"], rule exI[of _ "smult c r"], unfold p,
    insert q c, auto simp: c_def)
qed

lemma monic_irreducible_factorization: fixes p :: "'a :: field poly" 
  shows "monic p \<Longrightarrow> 
  \<exists> as f. finite as \<and> p = prod (\<lambda> a. a ^ Suc (f a)) as \<and> as \<subseteq> {q. irreducible q \<and> monic q}"
proof (induct "degree p" arbitrary: p rule: less_induct)
  case (less p)
  show ?case
  proof (cases "degree p = 0")
    case True
    with less(2) have "p = 1" by (simp add: coeff_eq_0 poly_eq_iff)
    thus ?thesis by (intro exI[of _ "{}"], auto)
  next
    case False
    from irreducible_factor[OF this] obtain q r where p: "p = q * r"
      and q: "irreducible q" and deg: "degree r < degree p" by auto
    hence q0: "q \<noteq> 0" unfolding irreducible_def by auto
    define c where "c = coeff q (degree q)"
    let ?q = "smult (1/c) q"
    let ?r = "smult c r"
    from q0 have c: "c \<noteq> 0" "1 / c \<noteq> 0" unfolding c_def by auto
    hence p: "p = ?q * ?r" unfolding p by auto
    have deg: "degree ?r < degree p" using c deg by auto
    let ?Q = "{q. irreducible q \<and> monic (q :: 'a poly)}"
    have mon: "monic ?q" unfolding c_def using q0 by auto
    from monic_factor[OF `monic p`[unfolded p] this] have "monic ?r" .
    from less(1)[OF deg this] obtain f as
      where as: "finite as" "?r = (\<Prod> a \<in>as. a ^ Suc (f a))"
        "as \<subseteq> ?Q" by blast
    from q c have irred: "irreducible ?q" by simp
    show ?thesis
    proof (cases "?q \<in> as")
      case False
      let ?as = "insert ?q as"
      let ?f = "\<lambda> a. if a = ?q then 0 else f a"
      have "p = ?q * (\<Prod> a \<in>as. a ^ Suc (f a))" unfolding p as by simp
      also have "(\<Prod> a \<in>as. a ^ Suc (f a)) = (\<Prod> a \<in>as. a ^ Suc (?f a))"
        by (rule prod.cong, insert False, auto)
      also have "?q * \<dots> = (\<Prod> a \<in> ?as. a ^ Suc (?f a))"
        by (subst prod.insert, insert as False, auto)
      finally have p: "p = (\<Prod> a \<in> ?as. a ^ Suc (?f a))" .
      from as(1) have fin: "finite ?as" by auto
      from as mon irred have Q: "?as \<subseteq> ?Q" by auto
      from fin p Q show ?thesis 
        by(intro exI[of _ ?as] exI[of _ ?f], auto)
    next
      case True
      let ?f = "\<lambda> a. if a = ?q then Suc (f a) else f a"
      have "p = ?q * (\<Prod> a \<in>as. a ^ Suc (f a))" unfolding p as by simp
      also have "(\<Prod> a \<in>as. a ^ Suc (f a)) = ?q ^ Suc (f ?q) * (\<Prod> a \<in>(as - {?q}). a ^ Suc (f a))"
        by (subst prod.remove[OF _ True], insert as, auto)
      also have "(\<Prod> a \<in>(as - {?q}). a ^ Suc (f a)) = (\<Prod> a \<in>(as - {?q}). a ^ Suc (?f a))"
        by (rule prod.cong, auto)
      also have "?q * (?q ^ Suc (f ?q) * \<dots> ) = ?q ^ Suc (?f ?q) * \<dots>"
        by (simp add: ac_simps)
      also have "\<dots> = (\<Prod> a \<in> as. a ^ Suc (?f a))"
        by (subst prod.remove[OF _ True], insert as, auto)
      finally have "p = (\<Prod> a \<in> as. a ^ Suc (?f a))" .
      with as show ?thesis 
        by (intro exI[of _ as] exI[of _ ?f], auto)
    qed
  qed
qed 

lemma linear_irreducible: assumes "degree p = 1"
  shows "irreducible p"
  by (rule irreducibleI, insert assms, auto)

lemma irreducible_dvd_smult:
  assumes "degree p \<noteq> 0" "irreducible q" "p dvd q"
  shows "\<exists> c. c \<noteq> 0 \<and> q = smult c p"
proof -
  from assms have "\<not> degree p < degree q" 
  and nz: "p \<noteq> 0" "q \<noteq> 0" unfolding irreducible_def by auto
  hence deg: "degree p \<ge> degree q" by auto
  from `p dvd q` obtain k where q: "q = k * p" unfolding dvd_def by (auto simp: ac_simps)
  with nz have "k \<noteq> 0" by auto
  from deg[unfolded q degree_mult_eq[OF `k \<noteq> 0` `p \<noteq> 0` ]] have "degree k = 0" 
    unfolding q by auto 
  then obtain c where k: "k = [: c :]" by (metis degree_0_id)
  with `k \<noteq> 0` have "c \<noteq> 0" by auto
  have "q = smult c p" unfolding q k by simp
  with `c \<noteq> 0` show ?thesis by auto
qed

subsection \<open>Map over Polynomial Coefficients\<close>

definition map_poly :: "('a::zero \<Rightarrow> 'b::zero) \<Rightarrow> 'a poly \<Rightarrow> 'b poly"
  where "map_poly f p = fold_coeffs (\<lambda>c. pCons (f c)) p 0"

lemma map_poly_simps:
  shows "map_poly f (pCons c p) =
    (if c = 0 \<and> p = 0 then 0 else pCons (f c) (map_poly f p))"
proof (cases "c = 0")
  case True note c0 = this show ?thesis
    proof (cases "p = 0")
      case True thus ?thesis using c0 unfolding map_poly_def by simp
      next case False thus ?thesis
        unfolding map_poly_def
        apply(subst fold_coeffs_pCons_not_0_0_eq) by auto
    qed
  next case False thus ?thesis
    unfolding map_poly_def
    apply (subst fold_coeffs_pCons_coeff_not_0_eq) by auto
qed

lemma map_poly_pCons[simp]:
  assumes "c \<noteq> 0 \<or> p \<noteq> 0"
  shows "map_poly f (pCons c p) = pCons (f c) (map_poly f p)"
  unfolding map_poly_simps using assms by auto

lemma map_poly_simp_0[simp]:
  shows "map_poly f 0 = 0" unfolding map_poly_def by simp

lemma map_poly_id[simp]: "map_poly (id::'a::zero \<Rightarrow> 'a) = id"
proof(rule ext)
  fix p::"'a poly" show "map_poly id p = id p" by (induct p; simp)
qed

lemma map_poly_map_poly:
  assumes f0: "f 0 = 0"
  shows "map_poly f (map_poly g p) = map_poly (f \<circ> g) p"
proof (induct p)
  case (pCons a p) show ?case
    proof(cases "g a \<noteq> 0 \<or> map_poly g p \<noteq> 0")
      case True show ?thesis
        unfolding map_poly_pCons[OF pCons(1)]
        unfolding map_poly_pCons[OF True]
        unfolding pCons(2)
        by simp
      next case False
        hence [simp]: "g a = 0" "map_poly g p = 0" by simp+
        show ?thesis
          unfolding map_poly_pCons[OF pCons(1)]
          unfolding pCons(2)[symmetric]
          by (simp add: f0)
    qed
qed simp

lemma map_poly_zero:
  assumes f: "\<forall>c. f c = 0 \<longrightarrow> c = 0"
  shows [simp]: "map_poly f p = 0 \<longleftrightarrow> p = 0"
  by (induct p; auto simp: map_poly_simps f)

lemma coeff_map_poly:
  assumes "f 0 = 0"
  shows "coeff (map_poly f p) i = f (coeff p i)"
proof(induct p arbitrary:i)
  case 0 show ?case using assms by simp
  next case (pCons c p)
    hence cp0: "\<not> (c = 0 \<and> p = 0)" by auto
    show ?case
    proof(cases "i = 0")
      case True thus ?thesis
        unfolding map_poly_simps using assms by simp
      next case False
        then obtain j where j: "i = Suc j" using not0_implies_Suc by blast
        show ?thesis
        unfolding map_poly_simps j
        using pCons by(simp add: cp0)
    qed
qed

lemma map_poly_monom:
  assumes "f 0 = 0" shows "map_poly f (monom a i) = monom (f a) i"
proof(induct i)
  case 0 show ?case
    unfolding monom_0 unfolding map_poly_simps using assms by simp
  next case (Suc i) show ?case
    unfolding monom_Suc unfolding map_poly_simps unfolding Suc
    using assms by simp
qed

lemma map_poly_ext:
  assumes "\<And>a. a \<in> set (coeffs p) \<Longrightarrow> f a = g a"
  shows "map_poly f p = map_poly g p"
  using assms by(induct p, auto)

lemma map_poly_add:
  assumes h0: "h 0 = 0"
      and h_add: "\<forall>p q. h (p + q) = h p + h q"
  shows "map_poly h (p + q) = map_poly h p + map_poly h q"
proof (induct p arbitrary: q)
  case (pCons a p) note pIH = this
    show ?case
    proof(induct "q")
      case (pCons b q) note qIH = this
        show ?case
          unfolding map_poly_pCons[OF qIH(1)]
          unfolding map_poly_pCons[OF pIH(1)]
          unfolding add_pCons
          unfolding pIH(2)[symmetric]
          unfolding h_add[rule_format,symmetric]
          unfolding map_poly_simps using h0 by auto
    qed auto
qed auto

subsection \<open>Morphismic properties of @{term "pCons 0"}\<close>

lemma monom_pCons_0_monom:
  "monom (pCons 0 (monom a n)) d = map_poly (pCons 0) (monom (monom a n) d)"
  apply (induct d)
  unfolding monom_0 unfolding map_poly_simps apply simp
  unfolding monom_Suc map_poly_simps by auto

lemma pCons_0_add: "pCons 0 (p + q) = pCons 0 p + pCons 0 q" by auto

lemma sum_pCons_0_commute:
  "sum (\<lambda>i. pCons 0 (f i)) S = pCons 0 (sum f S)"
  by(induct S rule: infinite_finite_induct;simp)

lemma pCons_0_as_mult:
  fixes p:: "'a :: comm_semiring_1 poly"
  shows "pCons 0 p = [:0,1:] * p" by auto



subsection \<open>Misc\<close>

fun expand_powers :: "(nat \<times> 'a)list \<Rightarrow> 'a list" where
  "expand_powers [] = []"
| "expand_powers ((Suc n, a) # ps) = a # expand_powers ((n,a) # ps)"
| "expand_powers ((0,a) # ps) = expand_powers ps"

lemma expand_powers: fixes f :: "'a \<Rightarrow> 'b :: comm_ring_1"
  shows "(\<Prod> (n,a) \<leftarrow> n_as. f a ^ n) = (\<Prod> a \<leftarrow> expand_powers n_as. f a)"
  by (rule sym, induct n_as rule: expand_powers.induct, auto)

lemma poly_smult_zero_iff: fixes x :: "'a :: idom" 
  shows "(poly (smult a p) x = 0) = (a = 0 \<or> poly p x = 0)"
  by simp

lemma poly_prod_list_zero_iff: fixes x :: "'a :: idom" 
  shows "(poly (prod_list ps) x = 0) = (\<exists> p \<in> set ps. poly p x = 0)"
  by (induct ps, auto)

lemma poly_mult_zero_iff: fixes x :: "'a :: idom" 
  shows "(poly (p * q) x = 0) = (poly p x = 0 \<or> poly q x = 0)"
  by simp

lemma poly_power_zero_iff: fixes x :: "'a :: idom" 
  shows "(poly (p^n) x = 0) = (n \<noteq> 0 \<and> poly p x = 0)"
  by (cases n, auto)


lemma sum_monom_0_iff: assumes fin: "finite S"
  and g: "\<And> i j. g i = g j \<Longrightarrow> i = j"
  shows "sum (\<lambda> i. monom (f i) (g i)) S = 0 \<longleftrightarrow> (\<forall> i \<in> S. f i = 0)" (is "?l = ?r")
proof -
  {
    assume "\<not> ?r"
    then obtain i where i: "i \<in> S" and fi: "f i \<noteq> 0" by auto
    let ?g = "\<lambda> i. monom (f i) (g i)"
    have "coeff (sum ?g S) (g i) = f i + sum (\<lambda> j. coeff (?g j) (g i)) (S - {i})"
      by (unfold sum.remove[OF fin i], simp add: coeff_sum)
    also have "sum (\<lambda> j. coeff (?g j) (g i)) (S - {i}) = 0"
      by (rule sum.neutral, insert g, auto)
    finally have "coeff (sum ?g S) (g i) \<noteq> 0" using fi by auto
    hence "\<not> ?l" by auto
  }
  thus ?thesis by auto
qed

lemma degree_prod_list_eq: assumes "\<And> p. p \<in> set ps \<Longrightarrow> (p :: 'a :: idom poly) \<noteq> 0"
  shows "degree (prod_list ps) = sum_list (map degree ps)" using assms
proof (induct ps)
  case (Cons p ps)
  show ?case unfolding prod_list.Cons
    by (subst degree_mult_eq, insert Cons, auto simp: prod_list_zero_iff)
qed simp

lemma degree_power_eq: assumes p: "p \<noteq> 0"
  shows "degree (p ^ n) = degree (p :: 'a :: idom poly) * n"
proof (induct n)
  case (Suc n)
  from p have pn: "p ^ n \<noteq> 0" by auto
  show ?case using degree_mult_eq[OF p pn] Suc by auto
qed simp

lemma coeff_Poly: "coeff (Poly xs) i = (nth_default 0 xs i)"
  unfolding nth_default_coeffs_eq[of "Poly xs", symmetric] coeffs_Poly by simp

lemma rsquarefree_def': "rsquarefree p = (p \<noteq> 0 \<and> (\<forall>a. order a p \<le> 1))"
proof -
  have "\<And> a. order a p \<le> 1 \<longleftrightarrow> order a p = 0 \<or> order a p = 1" by linarith
  thus ?thesis unfolding rsquarefree_def by auto
qed

lemma order_prod_list: "(\<And> p. p \<in> set ps \<Longrightarrow> p \<noteq> 0) \<Longrightarrow> order x (prod_list ps) = sum_list (map (order x) ps)"
  by (induct ps, auto, subst order_mult, auto simp: prod_list_zero_iff)

lemma irreducible_dvd_eq:
assumes "irreducible a"
and "irreducible b"
and "a dvd b"
and "monic a" and "monic b" 
shows "a = b"
  using assms
  by (metis (no_types, lifting) coeff_smult degree_smult_eq irreducibleD(1) irreducible_dvd_smult 
    mult.right_neutral smult_1_left)

lemma monic_irreducible_gcd: 
  "monic (f::'a::{field,euclidean_ring_gcd} poly) \<Longrightarrow> irreducible f \<Longrightarrow> gcd f u \<in> {1,f}"
  by (metis zero_neq_one gcd_dvd1 insert_iff irreducible_dvd_eq irreducible_dvd_smult 
    irreducible_smult leading_coeff_0_iff monic_degree_0 poly_gcd_monic)

lemma monic_gcd_dvd: assumes fg: "f dvd g" and mon: "monic f" and gcd: "gcd g h \<in> {1,g}"
  shows "gcd f h \<in> {1,f}"
proof (cases "gcd g h = 1")
  case True
  with fg show ?thesis by (metis coprime_divisors dvd_refl insertCI)
next
  case False
  with gcd have gcd: "gcd g h = g" by auto
  with fg mon show ?thesis
    by (metis dvd_gcdD2 gcd_proj1_iff insertI2 insert_absorb2 insert_eq_iff 
      insert_not_empty normalize_monic)
qed

lemma monom_power: "(monom a b)^n = monom (a^n) (b*n)" 
  by (induct n, auto simp add: mult_monom)

lemma poly_const_pow: "[:a:]^b = [:a^b:]"
  by (metis Groups.mult_ac(2) monom_0 monom_power mult_zero_right)

lemma degree_pderiv_le: "degree (pderiv f) \<le> degree f - 1" 
proof (rule ccontr)
  assume "\<not> ?thesis"
  hence ge: "degree (pderiv f) \<ge> Suc (degree f - 1)" by auto
  hence "pderiv f \<noteq> 0" by auto
  hence "coeff (pderiv f) (degree (pderiv f)) \<noteq> 0" by auto
  from this[unfolded coeff_pderiv]
  have "coeff f (Suc (degree (pderiv f))) \<noteq> 0" by auto
  moreover have "Suc (degree (pderiv f)) > degree f" using ge by auto
  ultimately show False by (simp add: coeff_eq_0)
qed

lemma map_div_is_smult_inverse: "Polynomial_Factorial.map_poly (\<lambda>x. x / (a :: 'a :: field)) p = smult (inverse a) p" 
  unfolding smult_conv_map_poly
  by (simp add: divide_inverse_commute)

lemma normalize_poly_old_def: "normalize (f :: 'a :: {normalization_semidom,field} poly) = 
  smult (inverse (unit_factor (lead_coeff f))) f" unfolding normalize_poly_def map_div_is_smult_inverse by simp

(* was in Euclidean_Algorithm in Number_Theory before, but has been removed *)
lemma poly_dvd_antisym:
  fixes p q :: "'b::idom poly"
  assumes coeff: "coeff p (degree p) = coeff q (degree q)"
  assumes dvd1: "p dvd q" and dvd2: "q dvd p" shows "p = q"
proof (cases "p = 0")
  case True with coeff show "p = q" by simp
next
  case False with coeff have "q \<noteq> 0" by auto
  have degree: "degree p = degree q"
    using \<open>p dvd q\<close> \<open>q dvd p\<close> \<open>p \<noteq> 0\<close> \<open>q \<noteq> 0\<close>
    by (intro order_antisym dvd_imp_degree_le)

  from \<open>p dvd q\<close> obtain a where a: "q = p * a" ..
  with \<open>q \<noteq> 0\<close> have "a \<noteq> 0" by auto
  with degree a \<open>p \<noteq> 0\<close> have "degree a = 0"
    by (simp add: degree_mult_eq)
  with coeff a show "p = q"
    by (cases a, auto split: if_splits)
qed

lemma coeff_f_0_code[code_unfold]: "coeff f 0 = (case coeffs f of [] \<Rightarrow> 0 | x # _ \<Rightarrow> x)" 
  by (cases f, auto simp: cCons_def)

lemma poly_compare_0_code[code_unfold]: "(f = 0) = (case coeffs f of [] \<Rightarrow> True | _ \<Rightarrow> False)" 
  using coeffs_eq_Nil list.disc_eq_case(1) by blast

lemma lead_coeff_code[code]: "lead_coeff f = (let xs = coeffs f in case xs of [] \<Rightarrow> 0 | _ \<Rightarrow> last xs)"
  by (metis (no_types, lifting) coeffs_0_eq_Nil last_coeffs_eq_coeff_degree lead_coeff_0 lead_coeff_def length_Suc_conv length_coeffs_degree list.simps(4) list.simps(5)) 

lemma nth_coeffs_coeff: "i < length (coeffs f) \<Longrightarrow> coeffs f ! i = coeff f i"
  by (metis nth_default_coeffs_eq nth_default_def)

lemma degree_prod_eq_sum_degree:
fixes A :: "'a set"
and f :: "'a \<Rightarrow> 'b::field poly"
assumes f0: "\<forall>i\<in>A. f i \<noteq> 0"
shows "degree (\<Prod>i\<in>A. (f i)) = (\<Sum>i\<in>A. degree (f i))"
using f0
proof (induct A rule: infinite_finite_induct)
  case (insert x A)
  have "(\<Sum>i\<in>insert x A. degree (f i)) = degree (f x) + (\<Sum>i\<in>A. degree (f i))"
    by (simp add: insert.hyps(1) insert.hyps(2))
  also have "... = degree (f x) + degree (\<Prod>i\<in>A. (f i))"
    by (simp add: insert.hyps insert.prems)
  also have "... = degree (f x * (\<Prod>i\<in>A. (f i)))"
  proof (rule degree_mult_eq[symmetric])
    show "f x \<noteq> 0" using insert.prems by auto
    show "prod f A \<noteq> 0" by (simp add: insert.hyps(1) insert.prems)
  qed
  also have "... = degree (\<Prod>i\<in>insert x A. (f i))"
    by (simp add: insert.hyps)
  finally show ?case ..
qed auto

definition monom_mult :: "nat \<Rightarrow> 'a :: comm_semiring_1 poly \<Rightarrow> 'a poly" where
  "monom_mult n f = monom 1 n * f" 
  
lemma monom_mult_unfold: "monom 1 n * f = monom_mult n f"
  "f * monom 1 n = monom_mult n f" 
  by (auto simp: monom_mult_def ac_simps)

declare monom_mult_unfold[code_unfold]

lemma monom_mult_code[code abstract]: "coeffs (monom_mult n f) = (let xs = coeffs f in
  if xs = [] then xs else replicate n 0 @ xs)" 
proof (cases "f = 0")
  case False
  hence cf: "(coeffs f = []) = False" by auto
  from False have last: "last (coeffs f) \<noteq> 0" by (rule last_coeffs_not_0)
  show ?thesis unfolding monom_mult_def Let_def cf if_False
  proof (rule coeffs_eqI)
    show "last (replicate n 0 @ coeffs f) \<noteq> 0" using cf last by auto
    fix i
    show "coeff (monom 1 n * f) i = nth_default 0 (replicate n 0 @ coeffs f) i" 
    proof (cases "n \<le> i")
      case True
      hence "coeff (monom 1 n * f) i = coeff f (i - n)" unfolding coeff_monom_mult by auto
      also have "\<dots> = nth_default 0 (replicate n 0 @ coeffs f) i" 
        unfolding nth_default_append[of _ _ _ i] nth_default_coeffs_eq using True by simp
      finally show ?thesis .
    next
      case False
      hence "coeff (monom 1 n * f) i = 0" unfolding coeff_monom_mult by auto
      also have "\<dots> = nth_default 0 (replicate n 0 @ coeffs f) i" using False
        unfolding nth_default_append[of _ _ _ i] by auto
      finally show ?thesis .
    qed
  qed
qed (auto simp: monom_mult_def)    

lemma coeff_pcompose_monom: fixes f :: "'a :: comm_ring_1 poly" 
  assumes n: "j < n" 
  shows "coeff (f \<circ>\<^sub>p monom 1 n) (n * i + j) = (if j = 0 then coeff f i else 0)"     
proof (induct f arbitrary: i)
  case (pCons a f i)
  note d = pcompose_pCons coeff_add coeff_monom_mult coeff_pCons
  show ?case 
  proof (cases i)
    case 0
    show ?thesis unfolding d 0 using n by (cases j, auto)
  next
    case (Suc ii)
    have id: "n * Suc ii + j - n = n * ii + j" using n by (simp add: diff_mult_distrib2)
    have id1: "(n \<le> n * Suc ii + j) = True" by auto
    have id2: "(case n * Suc ii + j of 0 \<Rightarrow> a | Suc x \<Rightarrow> coeff 0 x) = 0" using n
      by (cases "n * Suc ii + j", auto)
    show ?thesis unfolding d Suc id id1 id2 pCons(2) if_True by auto
  qed
qed auto


lemma coeff_pcompose_x_pow_n: fixes f :: "'a :: comm_ring_1 poly" 
  assumes n: "n \<noteq> 0" 
  shows "coeff (f \<circ>\<^sub>p monom 1 n) (n * i) = coeff f i"     
  using coeff_pcompose_monom[of 0 n f i] n by auto


end
