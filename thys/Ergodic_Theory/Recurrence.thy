(*  Author:  Sébastien Gouëzel   sebastien.gouezel@univ-rennes1.fr
    License: BSD
*)

theory Recurrence
imports Measure_Preserving_Transformations
begin


section{*Conservativity, recurrence*}

text{*A dynamical system is conservative if almost every point comes back close to its starting point.
This is always the case if the measure is finite, not when it is infinite (think of the translation
on $\mathbb{Z}$). In conservative systems, an important construction is the induced map: the first return
map to a set of finite measure. It is measure-preserving and conservative if the original system is.
This makes it possible to reduce statements about general conservative systems in infinite measure
to statements about systems in finite measure, and as such is extremely useful.*}

subsection {* Definition of conservativity *}

locale conservative = qmpt +
  assumes conservative: "\<And>A. A \<in> sets M \<Longrightarrow> emeasure M A > 0 \<Longrightarrow> \<exists>n>0. emeasure M ((T^^n)-`A \<inter> A) >0"

lemma conservativeI:
  assumes "qmpt M T"
    "\<And>A. A \<in> sets M \<Longrightarrow> emeasure M A > 0 \<Longrightarrow> \<exists>n>0. emeasure M ((T^^n)-`A \<inter> A) >0"
  shows "conservative M T"
unfolding conservative_def conservative_axioms_def using assms by auto

lemma conservativeI2:
  assumes "qmpt M T"
    "\<And>A. A \<in> sets M \<Longrightarrow> emeasure M A > 0 \<Longrightarrow> \<exists>n>0. (T^^n)-`A \<inter> A \<noteq> {}"
  shows "conservative M T"
unfolding conservative_def conservative_axioms_def
proof (auto simp add: assms)
  interpret qmpt M T using assms by auto
  fix A
  assume A_meas [measurable]: "A \<in> sets M" and "emeasure M A > 0"
  show "\<exists>n>0. 0 < emeasure M ((T ^^ n) -` A \<inter> A)"
  proof (rule ccontr)
    assume "\<not> (\<exists>n>0. 0 < emeasure M ((T ^^ n) -` A \<inter> A))"
    then have meas_0: "\<And>n. n > 0 \<Longrightarrow> emeasure M ((T ^^ n) -` A \<inter> A) = 0"
      by (metis zero_less_iff_neq_zero)
    define C where "C = (\<Union>n. (T^^(n+1))-`A \<inter> A)"
    have "\<And>n. (T^^n)-`A \<inter> A = (T^^n)--`A \<inter> A" using `A \<in> sets M`
      by (simp add: Int_assoc vimage_restr_def)
    then have *: "\<And>n. (T^^n)-`A \<inter> A \<in> sets M" using `A \<in> sets M` by auto
    then have C_meas [measurable]: "C \<in> sets M" using C_def by blast
    have "emeasure M C = 0" unfolding C_def
    proof (rule emeasure_UN_eq_0[of M, of "\<lambda>n. (T^^(n+1))-`A \<inter> A", OF meas_0])
      show "range (\<lambda>n. (T ^^ (n + 1)) -` A \<inter> A) \<subseteq> sets M" using * by blast
    qed (simp)

    define A2 where "A2 = A-C"
    then have A2_meas [measurable]: "A2 \<in> sets M" by simp
    have "\<not>(\<exists>n>0. (T^^n)-`A2 \<inter> A2 \<noteq> {})"
    proof (rule ccontr)
      assume "\<not> \<not>(\<exists>n>0. (T^^n)-`A2 \<inter> A2 \<noteq> {})"
      then obtain n where n: "n > 0" "(T^^n)-`A2 \<inter> A2 \<noteq> {}" by auto
      define m where "m = n-1"
      have "(T^^(m+1))-`A2 \<inter> A2 \<noteq> {}" unfolding m_def using n by auto
      then show False using C_def A2_def by auto
    qed
    then have "emeasure M A2 = 0" using assms(2)[OF A2_meas] by (meson zero_less_iff_neq_zero)
    then have "emeasure M (C \<union> A2) = 0" using `emeasure M C = 0` by (simp add: emeasure_Un_null_set null_setsI)
    moreover have "A \<subseteq> C \<union> A2" unfolding A2_def by auto
    ultimately have "emeasure M A = 0" by (meson A2_meas C_meas emeasure_eq_0 sets.Un)
    then show False using `emeasure M A > 0` by auto
  qed
qed

lemma
  assumes "A \<noteq> {}" "surj f"
  shows "f-`A \<noteq> {}"
by (simp add: assms(1) assms(2) surj_vimage_empty)

lemma (in conservative)
  assumes "invertible_qmpt"
  shows "conservative M Tinv"
proof (rule conservativeI2)
  show "qmpt M Tinv" using Tinv_qmpt[OF assms].
  have "bij T" using assms unfolding invertible_qmpt_def by auto
  fix A assume [measurable]: "A \<in> sets M" and "emeasure M A > 0"
  then obtain n where *: "n>0" "emeasure M ((T^^n)-`A \<inter> A) > 0"
    using conservative[OF `A \<in> sets M` `emeasure M A > 0`] by blast
  have "bij (T^^n)" using bij_fn[OF `bij T`] by auto
  then have "bij(inv (T^^n))" using bij_imp_bij_inv by auto
  then have "bij (Tinv^^n)" unfolding Tinv_def using inv_fn[OF `bij T`, of n] by auto

  have "(T^^n)-`A \<inter> A \<noteq> {}" using * by auto
  then have "(Tinv^^n)-`((T^^n)-`A \<inter> A) \<noteq> {}"
    using surj_vimage_empty[OF bij_is_surj[OF `bij (Tinv^^n)`]] by blast
  then have **: "(Tinv^^n)-`((T^^n)-`A) \<inter> (Tinv^^n)-` A \<noteq> {}"
    by auto

  have "(Tinv^^n)-`((T^^n)-`A) = ((T^^n) o (Tinv^^n))-`A"
    by auto
  moreover have "(T^^n) o (Tinv^^n) = (\<lambda>x. x)"
    unfolding Tinv_def using \<open>bij T\<close> fn_o_inv_fn_is_id by blast
  ultimately have "(Tinv^^n)-`((T^^n)-`A) = A" by auto
  then have "(Tinv^^n)-` A \<inter> A \<noteq> {}" using ** by auto
  then show "\<exists>n>0. (Tinv ^^ n) -` A \<inter> A \<noteq> {}" using `n>0` by auto
qed


locale conservative_mpt = mpt + conservative

lemma conservative_mptI:
  assumes "mpt M T"
    "\<And>A. A \<in> sets M \<Longrightarrow> emeasure M A > 0 \<Longrightarrow> \<exists>n>0. (T^^n)-`A \<inter> A \<noteq> {}"
  shows "conservative_mpt M T"
unfolding conservative_mpt_def
apply (auto simp add: assms(1), rule conservativeI2)
using assms(1) by (auto simp add: mpt_def assms(2))

text {* The fact that finite measure preserving transformations are conservative, albeit easy,
is extremely important. This result is known as Poincaré recurrence theorem.*}

sublocale fmpt \<subseteq> conservative_mpt
proof (rule conservative_mptI)
  show "mpt M T" by (simp add: mpt_axioms)
  fix A
  assume A_meas [measurable]: "A \<in> sets M" and "emeasure M A > 0"
  show "\<exists>n>0. (T^^n)-`A \<inter> A \<noteq> {}"
  proof (rule ccontr)
    assume "\<not>(\<exists>n>0. (T^^n)-`A \<inter> A \<noteq> {})"
    then have disj: "\<And>n. (T^^(n+1))--`A \<inter> A = {}" unfolding vimage_restr_def using zero_less_one by blast

    define B where "B = (\<lambda> n. (T^^n)--`A)"
    then have B_meas [measurable]: "\<And> n. B n \<in> sets M" by simp
    have same: "\<And> n. measure M (B n) = measure M A"
      by (simp add: B_def A_meas T_vrestr_same_measure(2))

    {
      fix m n::"nat"
      assume "n>m"
      have "B n \<inter> B m = (T^^m)--` (B (n-m) \<inter> A)"
        using B_def `m < n` A_meas vrestr_intersec T_vrestr_composed(1) by auto
      moreover have "B (n-m) \<inter> A = {}" unfolding B_def
        by (metis disj `m < n` Suc_diff_Suc Suc_eq_plus1)
      ultimately have "B n \<inter> B m = {}" by simp
    }
    then have "disjoint_family B" by (metis disjoint_family_on_def inf_sup_aci(1) less_linear)
    {
      fix e::real
      assume "e>0"
      obtain N::nat where "N>0" "(measure M (space M))/e<N" using `0 < e`
        by (metis divide_less_0_iff reals_Archimedean2 less_eq_real_def measure_nonneg not_gr0 not_le of_nat_0)
      then have "(measure M (space M))/N < e" using `0 < e` `N>0`
        by (metis bounded_measure div_0 le_less_trans measure_empty mult.commute pos_divide_less_eq)
      have *: "disjoint_family_on B {..<N}"
        by (meson UNIV_I `disjoint_family B` disjoint_family_on_mono subsetI)
      then have "(\<Sum>i\<in>{..<N}. measure M (B i)) \<le> measure M (space M)"
        by (metis bounded_measure `\<And>n. B n \<in> sets M`
            image_subset_iff finite_lessThan finite_measure_finite_Union)
      also have "(\<Sum>i\<in>{..<N}. measure M (B i)) = (\<Sum>i\<in>{..<N}. measure M A)" using same by simp
      also have "... = N * (measure M A)" by simp
      finally have "N * (measure M A) \<le> measure M (space M)" by simp
      then have "measure M A \<le> (measure M (space M))/N" using `N>0` by (simp add: mult.commute mult_imp_le_div_pos)
      then have "measure M A < e" using `(measure M (space M))/N<e` by simp
    }
    then have "measure M A \<le> 0" using not_less by blast
    then have "measure M A = 0" by (simp add: measure_le_0_iff)
    then have "emeasure M A = 0" using emeasure_eq_measure by simp
    then show False using `emeasure M A > 0` by simp
  qed
qed

text {* The following fact that powers of conservative maps are also conservative is true,
but nontrivial.*}

proposition (in conservative) conservative_power:
  "conservative M (T^^n)"
proof (unfold_locales)
  show "T ^^ n \<in> quasi_measure_preserving M M"
    by (auto simp add: Tn_quasi_measure_preserving)

  fix A assume "A \<in> sets M" "0 < emeasure M A"
  define good_time where "good_time = (\<lambda>K. Inf{(i::nat). i > 0 \<and> emeasure M ((T^^i)-`K \<inter> A) > 0})"
  define next_good_set where "next_good_set = (\<lambda>K. (T^^(good_time K))-`K \<inter> A)"

  have good_rec: "\<And>K. K \<in> sets M \<Longrightarrow> K \<subseteq> A \<Longrightarrow> emeasure M K > 0 \<Longrightarrow>
        ((good_time K > 0) \<and> (next_good_set K \<subseteq> A) \<and>
          (next_good_set K \<in> sets M) \<and> (emeasure M (next_good_set K) > 0))"
  proof -
    fix K
    assume "K \<in> sets M" "K \<subseteq> A" "emeasure M K > 0"
    have meas: "\<And>n. (T^^n)-`K \<inter> A \<in> sets M" by (metis vrestr_intersec_in_space
        inf_commute T_vrestr_meas(2) `A \<in> sets M` `K \<in> sets M` sets.Int)
    then have a: "next_good_set K \<in> sets M" "next_good_set K \<subseteq> A"
      using next_good_set_def by simp_all
    obtain k where "k > 0" and posK: "emeasure M ((T^^k)-`K \<inter> K) > 0"
      using conservative[OF `K \<in> sets M`, OF `emeasure M K > 0`] by auto
    have *:"(T^^k)-`K \<inter> K \<subseteq> (T^^k)-`K \<inter> A" using `K \<subseteq> A` by auto
    have posKA: "emeasure M ((T^^k)-`K \<inter> A) > 0" using emeasure_mono[OF *, OF meas[of k]] posK by simp
    let ?S = "{(i::nat). i>0 \<and> emeasure M ((T^^i)-`K \<inter> A) > 0}"
    have "k \<in> ?S" using `k>0` posKA by simp
    then have "?S \<noteq> {}" by auto
    then have "Inf ?S \<in> ?S" using Inf_nat_def1[of ?S] by simp
    then have "good_time K \<in> ?S" using good_time_def by simp
    then show "(good_time K > 0) \<and> (next_good_set K \<subseteq> A) \<and>
          (next_good_set K \<in> sets M) \<and> (emeasure M (next_good_set K) > 0)"
      using a next_good_set_def by auto
  qed

  define B where "B = (\<lambda>i. (next_good_set^^i) A)"
  define t where "t = (\<lambda>i. good_time (B i))"
  have good_B: "\<And>i. (B i \<subseteq> A) \<and> (B i \<in> sets M) \<and> (emeasure M (B i) > 0)"
  proof -
    fix i
    show "(B i \<subseteq> A) \<and> (B i \<in> sets M) \<and> (emeasure M (B i) > 0)"
    proof (induction i)
      case 0
      have "B 0 = A" using B_def by simp
      then show ?case using `B 0 = A` `A \<in> sets M` `emeasure M A > 0` by simp
    next
      case (Suc i)
      moreover have "B (i+1) = next_good_set (B i)" using B_def by simp
      ultimately show ?case using good_rec[of "B i"] by auto
    qed
  qed
  have t_pos: "\<And>i. t i > 0" using t_def by (simp add: good_B good_rec)

  define s where "s = (\<lambda>i k. (\<Sum>n \<in> {i..<i+k}. t n))"
  have "\<And>i k. B (i+k) \<subseteq> (T^^(s i k))-`A \<inter> A"
  proof -
    fix i k
    show "B (i+k) \<subseteq> (T^^(s i k))-`A \<inter> A"
    proof (induction k)
      case 0
      show ?case using s_def good_B[of i] by simp
    next
      case (Suc k)
      have "B(i+k+1) = (T^^(t (i+k)))-`(B (i+k)) \<inter> A" using t_def B_def next_good_set_def by simp
      moreover have "B(i+k) \<subseteq> (T^^(s i k))-`A" using Suc.IH by simp
      ultimately have "B(i+k+1) \<subseteq> (T^^(t (i+k)))-` (T^^(s i k))-`A \<inter> A" by auto
      then have "B(i+k+1) \<subseteq> (T^^(t(i+k) + s i k))-`A \<inter> A" by (simp add: add.commute funpow_add vimage_comp)
      moreover have "t(i+k) + s i k = s i (k+1)" using s_def by simp
      ultimately show ?case by simp
    qed
  qed
  moreover have "\<And>j. (T^^j)-`A \<inter> A \<in> sets M"
    by (metis vrestr_intersec_in_space inf_commute T_vrestr_meas(2) `A \<in> sets M` sets.Int)
  ultimately have *: "\<And>i k. emeasure M ((T^^(s i k))-`A \<inter> A) > 0" by (metis inf.orderE inf.strict_boundedE good_B emeasure_mono)

  show "\<exists>k>0. 0 < emeasure M (((T ^^ n) ^^ k) -` A \<inter> A)"
  proof (cases)
    assume "n=0"
    then have "((T ^^ n) ^^ 1) -` A = A" by simp
    then show ?thesis using `emeasure M A > 0` by auto
  next
    assume "\<not>(n=0)"
    then have "n > 0" by simp
    define u where "u = (\<lambda>i. s 0 i mod n)"
    have "range u \<subseteq> {..<n}" by (simp add: `0 < n` image_subset_iff u_def)
    then have "finite (range u)" using finite_nat_iff_bounded by auto
    then have "\<exists>i j. (i<j) \<and> (u i = u j)" by (metis finite_imageD infinite_UNIV_nat injI less_linear)
    then obtain i k where "k>0" "u i = u (i+k)" using less_imp_add_positive by blast
    moreover have "s 0 (i+k) = s 0 i + s i k" unfolding s_def by (simp add: sum_add_nat_ivl)
    ultimately have "(s i k) mod n = 0" using u_def nat_mod_cong by metis
    then obtain r where "s i k = n * r" by auto
    moreover have "s i k > 0" unfolding s_def
      using `k > 0` t_pos sum_strict_mono[of "{i..<i+k}", of "\<lambda>x. 0", of "\<lambda>x. t x"] by simp
    ultimately have "r > 0" by simp
    moreover have "emeasure M ((T^^(n * r))-`A \<inter> A) > 0" using * `s i k = n * r` by metis
    ultimately show ?thesis by (metis funpow_mult)
  qed
qed

proposition (in conservative_mpt) conservative_mpt_power:
  "conservative_mpt M (T^^n)"
using conservative_power mpt_power unfolding conservative_mpt_def by auto

lemma (in conservative) ae_disjoint_then_null:
  assumes "A \<in> sets M"
          "\<And>n. n > 0 \<Longrightarrow> A \<inter> (T^^n)-`A \<in> null_sets M"
  shows "A \<in> null_sets M"
by (metis Int_commute assms(1) assms(2) conservative zero_less_iff_neq_zero null_setsD1 null_setsI)

lemma (in conservative) disjoint_then_null:
  assumes "A \<in> sets M"
          "\<And>n. n > 0 \<Longrightarrow> A \<inter> (T^^n)-`A = {}"
  shows "A \<in> null_sets M"
by (rule ae_disjoint_then_null, auto simp add: assms)

context qmpt begin

definition recurrent_subset::"'a set \<Rightarrow> 'a set"
  where "recurrent_subset A = {x \<in> A. \<exists> n\<in> {1..}. (T^^n) x \<in> A}"

definition recurrent_subset_infty::"'a set \<Rightarrow> 'a set"
  where "recurrent_subset_infty A = A - (\<Union>n. (T^^n)-` (A - recurrent_subset A))"

lemma recurrent_subset_incl:
  "recurrent_subset A \<subseteq> A"
  "recurrent_subset_infty A \<subseteq> A"
  "recurrent_subset_infty A \<subseteq> recurrent_subset A"
proof -
  show "recurrent_subset A \<subseteq> A" "recurrent_subset_infty A \<subseteq> A"
    unfolding recurrent_subset_def recurrent_subset_infty_def by auto
  have "recurrent_subset_infty A \<subseteq> A - (T^^0)-` (A - recurrent_subset A)"
    unfolding recurrent_subset_infty_def by blast
  then show "recurrent_subset_infty A \<subseteq> recurrent_subset A" using `recurrent_subset A \<subseteq> A` by auto
qed

lemma recurrent_subset_meas [measurable]:
  assumes [measurable]: "A \<in> sets M"
  shows "recurrent_subset A \<in> sets M"
        "recurrent_subset_infty A \<in> sets M"
proof -
  have *: "recurrent_subset A = (\<Union>n\<in> {1..}. (T^^n)-`A \<inter> A)"
    using recurrent_subset_def by auto
  have "\<And>n. (T^^n)-`A \<inter> A = (T^^n)--`A \<inter> A" using `A \<in> sets M`
    by (simp add: Int_assoc vimage_restr_def)
  then have "\<And>n. (T^^n)-`A \<inter> A \<in> sets M" using `A \<in> sets M` by auto
  then show [measurable]: "recurrent_subset A \<in> sets M" using * by (metis (no_types, lifting) countable_Un_Int(1))

  have "recurrent_subset_infty A = A - (\<Union>n. (T^^n)--` (A - recurrent_subset A))" unfolding recurrent_subset_infty_def vimage_restr_def
    using sets.sets_into_space[OF `A \<in> sets M`] by auto
  then show "recurrent_subset_infty A \<in> sets M" using assms by auto
qed

lemma recurrent_subset_infty_inf_returns:
  "x \<in> recurrent_subset_infty A \<longleftrightarrow> (x \<in> A \<and> infinite {n. (T^^n) x \<in> A})"
proof
  assume *: "x \<in> recurrent_subset_infty A"
  have "infinite {n. (T^^n) x \<in> A}"
  proof (rule ccontr)
    assume "\<not>(infinite {n. (T^^n) x \<in> A})"
    then have F: "finite {n. (T^^n) x \<in> A}" by auto
    have "0 \<in> {n. (T^^n) x \<in> A}" using * recurrent_subset_incl(2) by auto
    then have NE: "{n. (T^^n) x \<in> A} \<noteq> {}" by blast
    define N where "N = Max {n. (T^^n) x \<in> A}"
    have "N \<in> {n. (T^^n) x \<in> A}" unfolding N_def using F NE using Max_in by auto
    then have "(T^^N) x \<in> A" by auto
    moreover have "x \<notin> (T^^N)-` (A - recurrent_subset A)" using * unfolding recurrent_subset_infty_def by auto
    ultimately have "(T^^N) x \<in> recurrent_subset A" by auto
    then have "(T ^^ N) x \<in> A \<and> (\<exists>n. n \<in> {1..} \<and> (T ^^ n) ((T ^^ N) x) \<in> A)"
      unfolding recurrent_subset_def by blast
    then obtain n where "n>0" "(T^^n) ((T^^N) x) \<in> A"
      by (metis atLeast_iff gr0I not_one_le_zero)
    then have "n+N \<in> {n. (T^^n) x \<in> A}" by (simp add: funpow_add)
    then show False unfolding N_def using `n>0` F NE
      by (metis Max_ge Nat.add_0_right add.commute nat_add_left_cancel_less not_le)
  qed
  then show "x \<in> A \<and> infinite {n. (T^^n) x \<in> A}" using * recurrent_subset_incl(2) by auto
next
  assume *: "(x \<in> A \<and> infinite {n. (T ^^ n) x \<in> A})"
  {
    fix n
    obtain N where "N>n" "(T^^N) x \<in> A" using *
      using infinite_nat_iff_unbounded by force
    define k where "k = N-n"
    then have "k>0" "N = n+k" using `N>n` by auto
    then have "(T^^k) ((T^^n) x) \<in> A"
      by (metis \<open>(T ^^ N) x \<in> A\<close> \<open>N = n + k\<close> add.commute comp_def funpow_add)
    then have "(T^^ n) x \<notin> A - recurrent_subset A"
      unfolding recurrent_subset_def using `k>0` by auto
  }
  then show "x \<in> recurrent_subset_infty A" unfolding recurrent_subset_infty_def using * by auto
qed

lemma recurrent_subset_rel_incl:
  assumes "A \<subseteq> B"
  shows "recurrent_subset A \<subseteq> recurrent_subset B"
        "recurrent_subset_infty A \<subseteq> recurrent_subset_infty B"
proof -
  show "recurrent_subset A \<subseteq> recurrent_subset B"
    unfolding recurrent_subset_def using recurrent_subset_infty_inf_returns assms by auto
  show "recurrent_subset_infty A \<subseteq> recurrent_subset_infty B"
    apply (auto, subst recurrent_subset_infty_inf_returns)
    using assms recurrent_subset_incl(2) infinite_nat_iff_unbounded_le recurrent_subset_infty_inf_returns by fastforce
qed

lemma recurrent_subset_infty_returns:
  assumes "x \<in> recurrent_subset_infty A" "(T^^n) x \<in> A"
  shows "(T^^n) x \<in> recurrent_subset_infty A"
proof (subst recurrent_subset_infty_inf_returns, rule ccontr)
  assume "\<not> ((T ^^ n) x \<in> A \<and> infinite {k. (T ^^ k) ((T ^^ n) x) \<in> A})"
  then have 1: "finite {k. (T^^k) ((T^^n) x) \<in> A}" using assms(2) by auto
  have "0 \<in> {k. (T^^k) ((T^^n) x) \<in> A}" using assms(2) by auto
  then have 2: "{k. (T^^k) ((T^^n) x) \<in> A} \<noteq> {}" by blast
  define M where "M = Max {k. (T^^k) ((T^^n) x) \<in> A}"
  have M_prop: "\<And>k. k > M \<Longrightarrow> (T^^k) ((T^^n) x) \<notin> A"
    unfolding M_def using 1 2 by auto
  {
    fix N assume *: "(T^^N) x \<in> A"
    have "N \<le> n+M"
    proof (cases)
      assume "N \<le> n"
      then show ?thesis by auto
    next
      assume "\<not>(N \<le> n)"
      then have "N > n" by simp
      define k where "k = N-n"
      have "N = n + k" unfolding k_def using `N > n` by auto
      then have "(T^^k) ((T^^n)x) \<in> A" using * by (simp add: add.commute funpow_add)
      then have "k \<le> M" using M_prop using not_le by blast
      then show ?thesis unfolding k_def by auto
    qed
  }
  then have "finite {N. (T^^N) x \<in> A}"
    by (metis (no_types, lifting) infinite_nat_iff_unbounded mem_Collect_eq not_less)
  moreover have "infinite {N. (T^^N) x \<in> A}"
    using recurrent_subset_infty_inf_returns assms(1) by auto
  ultimately show False by auto
qed

lemma recurrent_subset_of_recurrent_subset:
  "recurrent_subset_infty(recurrent_subset_infty A) = recurrent_subset_infty A"
proof
  show "recurrent_subset_infty (recurrent_subset_infty A) \<subseteq> recurrent_subset_infty A"
    using recurrent_subset_incl(2)[of A] recurrent_subset_rel_incl(2) by auto
  show "recurrent_subset_infty A \<subseteq> recurrent_subset_infty (recurrent_subset_infty A)"
    using recurrent_subset_infty_returns recurrent_subset_infty_inf_returns
    by (metis (no_types, lifting) Collect_cong subsetI)
qed

theorem (in conservative) Poincare_recurrence_thm:
  assumes [measurable]: "A \<in> sets M"
  shows "A - recurrent_subset A \<in> null_sets M"
        "A - recurrent_subset_infty A \<in> null_sets M"
        "A \<Delta> recurrent_subset A \<in> null_sets M"
        "A \<Delta> recurrent_subset_infty A \<in> null_sets M"
        "emeasure M (recurrent_subset A) = emeasure M A"
        "emeasure M (recurrent_subset_infty A) = emeasure M A"
proof -
  define B where "B = {x \<in> A. \<forall> n\<in>{1..}. (T^^n) x \<in> (space M - A)}"

  have rs: "recurrent_subset A = A - B"
    by (auto simp add: B_def recurrent_subset_def)
       (meson Tn_meas assms measurable_space sets.sets_into_space subsetCE)
  then have *: "A - recurrent_subset A = B" using B_def by blast

  have "B = (\<Inter> n\<in>{1..}. (T^^n)--`(space M - A)) \<inter> A"
    apply (auto simp add: vimage_restr_def B_def)
    using assms sets.sets_into_space by blast
  moreover have "(\<Inter> n\<in>{1..}. (T^^n)--`(space M - A)) \<inter> A \<in> sets M"
    using assms T_vrestr_meas(1) by measurable
  ultimately have B_meas [measurable]: "B \<in> sets M" by simp

  have "B \<in> null_sets M"
    by (rule disjoint_then_null, auto, auto simp add: B_def)
  then show "A - recurrent_subset A \<in> null_sets M" using * by simp

  then have *: "(\<Union>n. (T^^n)--`(A-recurrent_subset A)) \<in> null_sets M"
    using T_quasi_preserves_null2(2) by blast
  have "recurrent_subset_infty A = recurrent_subset_infty A \<inter> space M" using sets.sets_into_space by auto
  also have "... = A \<inter> space M - (\<Union>n. (T^^n)-`(A-recurrent_subset A) \<inter> space M)" unfolding recurrent_subset_infty_def by blast
  also have "... = A - (\<Union>n. (T^^n)--`(A-recurrent_subset A))" unfolding vimage_restr_def using sets.sets_into_space by auto
  finally have **: "recurrent_subset_infty A = A - (\<Union>n. (T ^^ n) --` (A - recurrent_subset A))" .
  then have "A - recurrent_subset_infty A \<subseteq> (\<Union>n. (T^^n)--`(A-recurrent_subset A))" by auto
  with * ** show "A - recurrent_subset_infty A \<in> null_sets M"
    by (simp add: Diff_Diff_Int null_set_Int1)

  have "A \<Delta> recurrent_subset A = A - recurrent_subset A" using recurrent_subset_incl(1)[of A] by blast
  then show "A \<Delta> recurrent_subset A \<in> null_sets M" using `A - recurrent_subset A \<in> null_sets M` by auto
  then show "emeasure M (recurrent_subset A) = emeasure M A"
    by (rule Delta_null_same_emeasure[symmetric], auto)

  have "A \<Delta> recurrent_subset_infty A = A - recurrent_subset_infty A" using recurrent_subset_incl(2)[of A] by blast
  then show "A \<Delta> recurrent_subset_infty A \<in> null_sets M" using `A - recurrent_subset_infty A \<in> null_sets M` by auto
  then show "emeasure M (recurrent_subset_infty A) = emeasure M A"
    by (rule Delta_null_same_emeasure[symmetric], auto)
qed

definition return_partition::"'a set \<Rightarrow> nat \<Rightarrow> 'a set"
  where "return_partition A k = A \<inter> (T^^k)--`A - (\<Union>i\<in>{0<..<k}. (T^^i)--`A)"

lemma return_partition_basics:
  assumes A_meas: "A \<in> sets M"
  shows "\<And>n. return_partition A n \<in> sets M"
        "disjoint_family (\<lambda>n. return_partition A (n+1))"
        "(\<Union>n. return_partition A (n+1)) = recurrent_subset A"
proof -
  show "\<And>n. return_partition A n \<in> sets M" unfolding return_partition_def
    using assms T_vrestr_meas(2) by measurable

  define B where "B = (\<lambda>n. A \<inter> (T^^(n+1))--`A)"
  have "\<And>n. return_partition A (n+1) = B n -(\<Union>i\<in>{0..<n}. B i)"
    unfolding return_partition_def B_def by (auto) (auto simp add: less_Suc_eq_0_disj)
  then have *: "\<And>n. return_partition A (n+1) = disjointed B n" using disjointed_def[of B] by simp
  then show "disjoint_family (\<lambda>n. return_partition A (n+1))" using disjoint_family_disjointed by auto

  have "recurrent_subset A = (\<Union>n\<in> {1..}. A \<inter> (T^^n)-`A)"
    using recurrent_subset_def by auto
  moreover have "\<And>n. A \<inter> (T^^n)-`A = A \<inter> (T^^n)--`A"
    unfolding vimage_restr_def using `A \<in> sets M` sets.sets_into_space by auto
  ultimately have "recurrent_subset A = (\<Union>n\<in> {1..}. A \<inter> (T^^n)--`A)" by simp
  then have "recurrent_subset A = (\<Union>n. B n)" unfolding B_def using atLeast_Suc_greaterThan by simp
  also have "... = (\<Union>n. return_partition A (n+1))" using * UN_disjointed_eq[of B] by simp
  finally show "(\<Union>n. return_partition A (n+1)) = recurrent_subset A" by simp
qed

subsection{*Local time controls*}

text{*The local time is the time that an orbit spends in a given set. Local time controls
are basic to all the forthcoming developments.*}

definition local_time::"'a set \<Rightarrow> nat \<Rightarrow> 'a \<Rightarrow> nat"
where "local_time A n x = card {i\<in>{..<n}. (T^^i) x \<in> A}"

lemma local_time_birkhoff:
  "local_time A n x = birkhoff_sum (indicator A::'a\<Rightarrow>nat) n x"
proof (induction n)
  case 0
  then show ?case unfolding local_time_def birkhoff_sum_def by simp
next
  case (Suc n)
  have "local_time A (n+1) x = local_time A n x + indicator A ((T^^n) x)"
  proof (cases)
    assume *: "(T^^n) x \<in> A"
    then have "{i\<in>{..<Suc n}. (T^^i) x \<in> A} = {i\<in>{..<n}. (T^^i) x \<in> A} \<union> {n}"
      by auto
    then have "card {i\<in>{..<Suc n}. (T^^i) x \<in> A} = card {i\<in>{..<n}. (T^^i) x \<in> A} + card {n}"
      using card_Un_disjoint by auto
    then have "local_time A (n+1) x = local_time A n x + 1" using local_time_def by simp
    moreover have "indicator A ((T^^n)x) = (1::nat)" using * indicator_def by auto
    ultimately show ?thesis by simp
  next
    assume *: "\<not>((T^^n) x \<in> A)"
    then have "{i\<in>{..<Suc n}. (T^^i) x \<in> A} = {i\<in>{..<n}. (T^^i) x \<in> A}" using less_Suc_eq by force
    then have "card {i\<in>{..<Suc n}. (T^^i) x \<in> A} = card {i\<in>{..<n}. (T^^i) x \<in> A}"
      by auto
    then have "local_time A (n+1) x = local_time A n x" using local_time_def by simp
    moreover have "indicator A ((T^^n)x) = (0::nat)" using * indicator_def by auto
    ultimately show ?thesis by simp
  qed
  then have "local_time A (n+1) x = birkhoff_sum (indicator A) n x + indicator A ((T^^n) x)"
    using Suc.IH by auto
  moreover have "birkhoff_sum (indicator A) (n+1) x = birkhoff_sum (indicator A) n x + indicator A ((T^^n) x)"
    by (metis birkhoff_sum_cocycle[where ?n="n" and ?m="1"] birkhoff_sum_1(2))
  ultimately have "local_time A (n+1) x = birkhoff_sum (indicator A) (n+1) x" by metis
  then show ?case by (metis Suc_eq_plus1)
qed

lemma local_time_meas [measurable]:
  assumes [measurable]: "A \<in> sets M"
  shows "local_time A n \<in> measurable M (count_space UNIV)"
proof -
  have "birkhoff_sum(indicator A::'a\<Rightarrow>nat) n \<in> measurable M (count_space UNIV)"
    using assms measurable_simple_function birkhoff_sum_meas_nat[of "indicator A", of n] by blast
  then show ?thesis by (metis measurable_cong local_time_birkhoff)
qed

lemma local_time_cocycle:
  "local_time A n x + local_time A m ((T^^n)x) = local_time A (n+m) x"
by (metis local_time_birkhoff birkhoff_sum_cocycle)

lemma local_time_incseq:
  "incseq (\<lambda>n. local_time A n x)"
using local_time_cocycle incseq_def by (metis le_iff_add)

lemma local_time_Suc:
  "local_time A (n+1) x = local_time A n x + indicator A ((T^^n)x)"
by (metis local_time_birkhoff birkhoff_sum_cocycle birkhoff_sum_1(2))

lemma local_time_bound:
  "local_time A n x \<le> n"
proof -
  have "card {i\<in>{..<n}. (T^^i) x \<in> A} \<le> card {..<n}" by (rule card_mono, auto)
  then show ?thesis unfolding local_time_def by auto
qed

lemma (in conservative_mpt) local_time_unbounded1:
  assumes A_meas [measurable]: "A \<in> sets M"
    and fin: "emeasure M A < \<infinity>"
  shows "(\<lambda>n. emeasure M {x \<in> (T^^n)--`A. local_time A n x < k}) \<longlonglongrightarrow> 0"
proof (induction k)
  case 0
  have "\<And>n. {x \<in> (T^^n)--`A. local_time A n x < 0} = {}" by simp
  then show ?case by simp
next
  case (Suc k)
  define K where "K = (\<lambda>p n. {x \<in> (T^^n)--`A. local_time A n x < p})"
  have K_meas: "\<And>p n::nat. K p n \<in> sets M"
  proof -
    fix p n::nat
    have "{x \<in> (T^^n)--`A. local_time A n x < p} = (T^^n)--`A \<inter> (\<Union>i<p. (local_time A n)-`{i})"
      by blast
    then have "{x \<in> (T^^n)--`A. local_time A n x < p} = (T^^n)--`A \<inter> (\<Union>i<p. (local_time A n)-`{i} \<inter> space M)"
      using vimage_restr_def by auto
    also have "... \<in> sets M" by measurable
    finally show "K p n \<in> sets M" unfolding K_def .
  qed

  show ?case
  proof (rule tendsto_zero_ennreal)
    fix e :: real assume "0 < e"
    define e2 where "e2 = e/3"
    have "e2 > 0" using e2_def `e>0` by simp
    have "(\<Sum>n. emeasure M (return_partition A (n+1))) = emeasure M ((\<Union>n. return_partition A (n + 1)))"
      using return_partition_basics[OF A_meas] suminf_emeasure[of "\<lambda>n. return_partition A (n + 1)"] by force
    also have "... = emeasure M (recurrent_subset A)"
      using return_partition_basics(3)[OF A_meas] by simp
    also have "... = emeasure M A"
      by (metis A_meas double_diff emeasure_Diff_null_set order_refl Poincare_recurrence_thm(1)[OF A_meas] recurrent_subset_incl(1))
    finally have "(\<Sum>n. emeasure M (return_partition A (n+1))) = emeasure M A" by simp
    moreover have "summable (\<lambda>n. emeasure M (return_partition A (n+1)))"
      by simp
    ultimately have "(\<lambda>N. (\<Sum>n<N. emeasure M (return_partition A (n+1)))) \<longlonglongrightarrow> emeasure M A"
      unfolding sums_def[symmetric] sums_iff by simp
    then have "(\<lambda>N. (\<Sum>n<N. emeasure M (return_partition A (n+1))) + e2) \<longlonglongrightarrow> emeasure M A + e2"
      by (intro tendsto_add) auto
    moreover have "emeasure M A < emeasure M A + e2"
      using \<open>emeasure M A < \<infinity>\<close> \<open>0 < e2\<close> by auto
    ultimately have "eventually (\<lambda>N. (\<Sum>n<N. emeasure M (return_partition A (n+1))) + e2 > emeasure M A) sequentially"
      by (simp add: order_tendsto_iff)
    then obtain N where "N>0" and largeM: "(\<Sum>n<N. emeasure M (return_partition A (n+1))) + e2 > emeasure M A"
      by (metis (no_types, lifting) add.commute add_Suc_right eventually_at_top_linorder le_add2 zero_less_Suc)

    have upper: "\<And>n. n > N \<Longrightarrow> emeasure M (K (Suc k) n) \<le> e2 + (\<Sum>i<N. emeasure M (K k (n-i-1)))"
    proof -
      fix n
      assume "n > N"
      define B where "B = (\<lambda>i. (T^^(n-i-1))--`(return_partition A (i+1)))"
      have disj_B: "disjoint_family_on B {..<N}"
      proof -
        {
          fix i j
          assume "i\<in>{..<N}" "j\<in>{..<N}" "i < j"
          then have "n > i" "n>j" using `n>N` by auto
          let ?k = "j-i"
          {
            fix x
            assume "x \<in> B j"
            then have "(T^^(n-j-1)) x \<in> return_partition A (j+1)" using B_def vimage_restr_def by auto
            moreover have "?k>0" using `i < j` by simp
            moreover have "?k < j+1" by simp
            ultimately have "(T^^(n-j-1)) x \<notin> (T^^?k)--`A" using return_partition_def by auto
            then have "x \<notin> (T^^(n-j-1))-` (T^^?k)--`A" by simp
            then have "x \<notin> (T^^(n-j-1))--` (T^^?k)--`A" using vimage_restr_def by auto
            then have "x \<notin> (T^^(n-j-1 + ?k))--`A" using T_vrestr_composed[OF A_meas] by simp
            then have "x \<notin> (T^^(n-i-1))--`A" using `i<j` `n>j` by auto
            then have "x \<notin> (T^^(n-i-1))--` (return_partition A (i+1))" using return_partition_def by auto
            then have "x \<notin> B i" using B_def by auto
          }
          then have "B i \<inter> B j = {}" by auto
        }
        then have "\<And>i j. i\<in>{..<N} \<Longrightarrow> j\<in>{..<N} \<Longrightarrow> i \<noteq> j \<Longrightarrow> B i \<inter> B j = {}"
          by (metis Int_commute linorder_neqE_nat)
        then show ?thesis unfolding disjoint_family_on_def by auto
      qed

      have incl_B: "\<And>i. i \<in> {..<N} \<Longrightarrow> B i \<subseteq> (T^^n)--`A"
      proof -
        fix i assume "i \<in> {..<N}"
        then have "n > i" using `n>N` by auto
        have "B i \<subseteq> (T^^(n-i-1))--` (T^^(i+1))--` A"
          using B_def return_partition_def by auto
        then show "B i \<subseteq> (T^^n)--`A"
          using T_vrestr_composed(1)[OF A_meas, of "n-i-1", of "i+1"] `n>i` by auto
      qed

      define R where "R = (T^^n)--`A - (\<Union>i \<in> {..<N}. B i)"
      have B_meas: "\<And>i. B i \<in> sets M" using B_def return_partition_basics(1)[OF A_meas] T_vrestr_meas(2) by auto
      then have R_meas: "R \<in> sets M" using R_def T_vrestr_meas(2)[OF A_meas] by auto
      have dec_n: "(T^^n)--`A = R \<union> (\<Union>i \<in> {..<N}. B i)" using R_def incl_B by blast
      have small_R: "emeasure M R < e2"
      proof -
        have "R \<inter> (\<Union>i \<in> {..<N}. B i) = {}" using R_def by blast
        then have "emeasure M ((T^^n)--`A) = emeasure M R + emeasure M (\<Union>i \<in> {..<N}. B i)"
          using B_meas R_meas plus_emeasure[of R, of M, of "\<Union>i \<in> {..<N}. B i"] dec_n by auto
        moreover have "emeasure M (\<Union>i \<in> {..<N}. B i) = (\<Sum>i \<in> {..<N}. emeasure M (B i))"
          using B_meas disj_B sum_emeasure[where ?I = "{..<N}" and ?F = "B"] by force
        ultimately have "emeasure M ((T^^n)--`A) = emeasure M R + (\<Sum>i \<in> {..<N}. emeasure M (B i))"
          by simp
        moreover have "emeasure M ((T^^n)--`A) = emeasure M A"
          using T_vrestr_same_emeasure(2)[OF A_meas] by simp
        moreover have "\<And>i. emeasure M (B i) = emeasure M (return_partition A (i+1))"
          using T_vrestr_same_emeasure(2) B_def return_partition_basics(1)[OF A_meas] by simp
        ultimately have a: "emeasure M A = emeasure M R + (\<Sum>i \<in> {..<N}. emeasure M (return_partition A (i+1)))"
          by simp
        moreover have b: "(\<Sum>i \<in> {..<N}. emeasure M (return_partition A (i+1))) \<noteq> \<infinity>" using fin
          by (simp add: a less_top)
        ultimately show ?thesis
          using largeM fin b by simp
      qed

      have "K (Suc k) n \<subseteq> R \<union> (\<Union>i<N. K k (n-i-1))"
      proof
        fix x
        assume a: "x \<in> K (Suc k) n"
        show "x \<in> R \<union> (\<Union>i<N. K k (n-i-1))"
        proof (cases)
          assume "x \<in> R"
          then show ?thesis by simp
        next
          assume "\<not>(x \<in> R)"
          have "x \<in> (T^^n)--`A" using a K_def by simp
          then have "x\<in> (\<Union>i \<in> {..<N}. B i)" using dec_n `\<not>(x \<in> R)` by simp
          then obtain i where "i\<in>{..<N}" "x \<in> B i" by auto
          then have "n>i" using `n>N` by auto
          then have "(T^^(n-i-1)) x \<in> return_partition A (i+1)" using B_def `x \<in> B i` vimage_restr_def by auto
          then have i: "(T^^(n-i-1)) x \<in> A" using return_partition_def by auto
          then have "indicator A ((T^^(n-i-1)) x) = (1::nat)" by auto
          then have "local_time A (n-i) x = local_time A (n-i-1) x + 1"
            by (metis Suc_diff_Suc Suc_eq_plus1 diff_diff_add local_time_Suc[of A, of "n-i-1"] `n>i`)
          then have "local_time A (n-i) x > local_time A (n-i-1) x" by simp
          moreover have "local_time A n x \<ge> local_time A (n-i) x" using local_time_incseq
            by (metis `i < n` le_add_diff_inverse2 less_or_eq_imp_le local_time_cocycle le_iff_add)
          ultimately have "local_time A n x > local_time A (n-i-1) x" by simp
          moreover have "local_time A n x < Suc k" using a K_def by simp
          ultimately have *: "local_time A (n-i-1) x < k" by simp

          have "x \<in> space M" using `x \<in> (T^^n)--\`A` vimage_restr_def by auto
          then have "x \<in> (T^^(n-i-1))--`A" using i A_meas vimage_restr_def by (metis IntI sets.Int_space_eq2 vimageI)
          then have "x \<in> K k (n-i-1)" using * K_def by blast
          then show ?thesis using `i\<in>{..<N}` by auto
        qed
      qed

      moreover have "R \<union> (\<Union>i<N. K k (n-i-1)) \<in> sets M" using K_meas R_meas by auto
      ultimately have "emeasure M (K (Suc k) n) \<le> emeasure M (R \<union> (\<Union>i<N. K k (n-i-1)))"
        using emeasure_mono by simp
      also have "... \<le> emeasure M R + emeasure M (\<Union>i<N. K k (n-i-1))"
        using emeasure_subadditive[where ?A = R and ?B = "(\<Union>i<N. K k (n-i-1))"] K_meas R_meas by auto
      also have "... \<le> emeasure M R + (\<Sum>i<N. emeasure M (K k (n-i-1)))"
        by (metis add_left_mono image_subset_iff emeasure_subadditive_finite[where ?A = "\<lambda>i. K k (n-i-1)" and ?I = "{..<N}", OF finite_lessThan[of N]] K_meas)
      also have "... \<le> e2 + (\<Sum>i<N. emeasure M (K k (n-i-1)))"
        using small_R by (auto intro!: add_right_mono)
      finally show "emeasure M (K (Suc k) n) \<le> e2 + (\<Sum>i<N. emeasure M (K k (n-i-1)))" .
    qed

    have "(\<lambda>n. emeasure M (K k n)) \<longlonglongrightarrow> 0" using Suc.IH K_def by simp
    then have "\<And>i. (\<lambda>n. emeasure M (K k (n-i-1))) \<longlonglongrightarrow> 0" using seq_offset_neg by auto
    then have "(\<lambda>n. (\<Sum>i\<in>{..<N}. emeasure M (K k (n-i-1)))) \<longlonglongrightarrow> 0"
      using tendsto_sum [of "{..<N}" _ "\<lambda>_. 0"] by fastforce
    then have "eventually (\<lambda>n. (\<Sum>i\<in>{..<N}. emeasure M (K k (n-i-1))) < e2) sequentially"
      using `e2 > 0` by (simp add: order_tendsto_iff)
    then obtain N2 where N2bound: "\<And>n. n > N2 \<Longrightarrow> (\<Sum>i\<in>{..<N}. emeasure M (K k (n-i-1))) < e2"
      by (meson eventually_at_top_dense)
    define N3 where "N3 = max N N2"
    have "\<And>n. n > N3 \<Longrightarrow> emeasure M (K (Suc k) n) < e"
    proof -
      fix n
      assume "n > N3"
      then have "n>N2" "n > N" using N3_def by auto
      then have "emeasure M (K (Suc k) n) \<le> e2 + (\<Sum>i\<in>{..<N}. emeasure M (K k (n-i-1)))"
        using upper by simp
      also have "(\<Sum>i\<in>{..<N}. emeasure M (K k (n-i-1))) < e2" using N2bound `n > N2` by auto
      finally have "emeasure M (K (Suc k) n) \<le> ennreal e2 + ennreal e2"
        by (simp add: add_mono)
      moreover have "ennreal e2 + ennreal e2 < e" using e2_def `e > 0`
        by (auto simp add: ennreal_plus[symmetric] simp del: ennreal_plus intro!: ennreal_lessI)
      ultimately show "emeasure M (K (Suc k) n) < e" using le_less_trans by blast
    qed
    then show "\<forall>\<^sub>F x in sequentially. emeasure M {xa \<in> (T ^^ x) --` A. local_time A x xa < Suc k} < ennreal e"
      unfolding K_def by (auto simp: eventually_at_top_dense intro!: exI[of _ N3])
  qed
qed

lemma (in conservative_mpt) local_time_unbounded2:
  assumes A_meas [measurable]: "A \<in> sets M"
      and fin: "emeasure M A < \<infinity>"
      and incl: "A \<subseteq> (T^^i)--`B"
  shows "(\<lambda>n. emeasure M {x \<in> (T^^n)--`A. local_time B n x < k}) \<longlonglongrightarrow> 0"
proof -
  {
    fix n::nat
    assume "n > i"
    have "\<And>x. local_time A n x \<le> local_time B n x + i"
    proof -
      fix x
      have "local_time B n x \<ge> local_time A (n-i) x"
      proof -
        define KA where "KA = {t \<in> {0..<n-i}. (T^^t) x \<in> A}"
        define KB where "KB = {t \<in> {0..<n}. (T^^t) x \<in> B}"
        then have "KB \<subseteq> {0..<n}" by auto
        then have "finite KB" using finite_lessThan[of n] finite_subset by auto
        let ?g = "\<lambda>t. t + i"
        have "\<And>t. t \<in> KA \<Longrightarrow> ?g t \<in> KB"
        proof -
          fix t assume "t \<in> KA"
          then have "(T^^t) x \<in> A" using KA_def by simp
          then have "(T^^i) ((T^^t) x) \<in> B" using incl vimage_restr_def by auto
          then have "(T^^(t+i)) x \<in> B" by (simp add: funpow_add add.commute)
          moreover have "t+i < n" using `t \<in> KA` KA_def `n > i` by auto
          ultimately show "?g t \<in> KB" unfolding KB_def by simp
        qed
        then have "?g`KA \<subseteq> KB" by auto
        moreover have "inj_on ?g KA" by simp
        ultimately have "card KB \<ge> card KA"
          using card_inj_on_le[where ?f = "?g" and ?A = KA and ?B = KB] `finite KB` by simp
        then show ?thesis using KA_def KB_def local_time_def by simp
      qed
      moreover have "i \<ge> local_time A i ((T^^(n-i))x)" using local_time_bound by auto
      ultimately show "local_time B n x + i \<ge> local_time A n x"
        using local_time_cocycle[where ?n = "n-i" and ?m = i and ?x = x and ?A = A] `n>i` by auto
    qed
    then have "\<And>x. local_time B n x < k \<Longrightarrow> local_time A n x < k + i"
      by (meson add_le_cancel_right le_trans not_less)
    then have i: "{x \<in> (T^^n)--`A. local_time B n x < k} \<subseteq> {x \<in> (T^^n)--`A. local_time A n x < k + i}"
      by blast

    have "{x \<in> (T^^n)--`A. local_time A n x < k + i} = (T^^n)--`A \<inter> ((local_time A n)-`{..<k+i} \<inter> space M)"
      using vimage_restr_def A_meas by blast
    also have "... \<in> sets M" by measurable
    finally have "{x \<in> (T^^n)--`A. local_time A n x < k + i} \<in> sets M" .
    then have "emeasure M {x \<in> (T^^n)--`A. local_time B n x < k} \<le> emeasure M {x \<in> (T^^n)--`A. local_time A n x < k + i}"
      by (rule emeasure_mono[OF i])
  }
  then have a: "eventually (\<lambda>n. emeasure M {x \<in> (T^^n)--`A. local_time B n x < k}
                \<le> emeasure M {x \<in> (T^^n)--`A. local_time A n x < k + i}) sequentially"
    using eventually_at_top_dense by blast
  from tendsto_sandwich[OF _ this tendsto_const local_time_unbounded1[OF A_meas fin, of "k+i"]]
  show ?thesis by auto
qed

lemma (in conservative_mpt) local_time_unbounded3:
  assumes A_meas[measurable]: "A \<in> sets M"
      and B_meas[measurable]: "B \<in> sets M"
      and fin: "emeasure M A < \<infinity>"
      and incl: "A - (\<Union>i. (T^^i)--`B) \<in> null_sets M"
  shows "(\<lambda>n. emeasure M {x \<in> (T^^n)--`A. local_time B n x < k}) \<longlonglongrightarrow> 0"
proof -
  define R where "R = A - (\<Union>i. (T^^i)--`B)"
  have R_meas[measurable]: "R \<in> sets M"
    by (simp add: A_meas B_meas T_vrestr_meas(2)[OF B_meas] R_def countable_Un_Int(1) sets.Diff)
  have "emeasure M R = 0" using incl R_def by auto
  define A2 where "A2 = A - R"
  have A2_meas: "A2 \<in> sets M" using A2_def A_meas R_meas by simp
  have meq: "emeasure M A2 = emeasure M A" using `emeasure M R = 0`
    unfolding A2_def by (subst emeasure_Diff) (auto simp: R_def)
  then have A2_fin: "emeasure M A2 < \<infinity>" using fin by auto
  define K where "K = (\<lambda>N. A2 \<inter> (\<Union>i<N. (T^^i)--`B))"
  have K_incl: "\<And>N. K N \<subseteq> A" using K_def A2_def by blast
  have "(\<Union>N. K N) = A2" using A2_def R_def K_def by blast
  moreover have "incseq K" unfolding K_def incseq_def by fastforce
  moreover have K_meas: "\<And> N. K N \<in> sets M" unfolding K_def
    using A2_meas B_meas T_vrestr_meas(2)[OF B_meas] by measurable
  ultimately have "(\<lambda>N. emeasure M (K N)) \<longlonglongrightarrow> emeasure M A2" using Lim_emeasure_incseq by auto
  then have conv: "(\<lambda>N. emeasure M (K N)) \<longlonglongrightarrow> emeasure M A" using meq by simp

  define Bad where "Bad = (\<lambda>U n. {x \<in> (T^^n)--`U. local_time B n x < k})"
  define Bad0 where "Bad0 = (\<lambda>n. {x \<in> space M. local_time B n x < k})"
  then have "\<And>n. Bad0 n = (local_time B n)-`{..<k} \<inter> space M" by blast
  then have Bad0_meas: "\<And>n. Bad0 n \<in> sets M" using local_time_meas[OF B_meas] by simp
  have Bad_inter: "\<And>U n. Bad U n = (T^^n)--`U \<inter> Bad0 n" unfolding Bad_def Bad0_def using vimage_restr_def by blast
  then have Bad_meas: "\<And>U n. U \<in> sets M \<Longrightarrow> Bad U n \<in> sets M" using T_vrestr_meas(2) Bad0_meas by simp

  show ?thesis
  proof (rule tendsto_zero_ennreal)
    fix e::real
    assume "e > 0"
    define e2 where "e2 = e/3"
    then have "e2 > 0" using `e>0` by simp
    then have "ennreal e2 > 0" by simp
    have "(\<lambda>N. emeasure M (K N) + e2) \<longlonglongrightarrow> emeasure M A + e2"
      using conv by (intro tendsto_add) auto
    moreover have "emeasure M A < emeasure M A + e2" using fin `e2 > 0` by simp
    ultimately have "eventually (\<lambda>N. emeasure M (K N) + e2 > emeasure M A) sequentially"
      by (simp add: order_tendsto_iff)
    then obtain N where "N>0" and largeK: "emeasure M (K N) + e2 > emeasure M A"
      by (metis (no_types, lifting) add.commute add_Suc_right eventually_at_top_linorder le_add2 zero_less_Suc)
    define S where "S = A - (K N)"
    have S_meas: "S \<in> sets M" using A_meas K_meas S_def by simp
    have "emeasure M A = emeasure M (K N) + emeasure M S"
      by (metis Diff_disjoint Diff_partition plus_emeasure[OF K_meas[of N], OF S_meas] S_def K_incl[of N])
    then have S_small: "emeasure M S < e2" using largeK fin by simp
    have A_incl: "A \<subseteq> S \<union> (\<Union>i<N. A2 \<inter> (T^^i)--`B)" using S_def K_def by auto

    define L where "L = (\<lambda>i. A2 \<inter> (T^^i)--`B)"
    have L_meas: "\<And>i. L i \<in> sets M" using A2_meas B_meas T_vrestr_meas(2)[OF B_meas] L_def by auto
    have "\<And>i. L i \<subseteq> A2" using L_def by simp
    then have L_fin: "emeasure M (L i) < \<infinity>" for i
      using emeasure_mono[of "L i" A2 M] A2_meas A2_fin by simp
    have "\<And>i. L i \<subseteq> (T^^i)--`B" using L_def by auto
    then have a: "\<And>i. (\<lambda>n. emeasure M (Bad (L i) n)) \<longlonglongrightarrow> 0" unfolding Bad_def
      using local_time_unbounded2[OF L_meas, OF L_fin] by blast
    have "(\<lambda>n. (\<Sum>i<N. emeasure M (Bad (L i) n))) \<longlonglongrightarrow> 0" using tendsto_sum[OF a] by auto
    then have "eventually (\<lambda>n. (\<Sum>i<N. emeasure M (Bad (L i) n)) < e2) sequentially"
      using `ennreal e2 > 0` order_tendsto_iff by metis
    then obtain N2 where *: "\<And>n. n > N2 \<Longrightarrow> (\<Sum>i<N. emeasure M (Bad (L i) n)) < e2"
      by (auto simp add: eventually_at_top_dense)

    {
      fix n::nat
      assume "n > N2"
      have "Bad S n \<subseteq> (T^^n)--`S" unfolding Bad_def by auto
      then have "emeasure M (Bad S n) \<le> emeasure M ((T^^n)--`S)"
        using emeasure_mono S_meas T_vrestr_meas(2) by force
      also have "... = emeasure M S" using T_vrestr_same_emeasure(2) S_meas by simp
      also have "... \<le> e2" using S_small by simp
      finally have SBad_small: "emeasure M (Bad S n) \<le> e2" by simp

      have "(T^^n)--`A \<subseteq> (T^^n)--`S \<union> (\<Union>i<N. (T^^n)--`(L i))"
        using A_incl unfolding L_def vimage_restr_def by fastforce
      then have "Bad A n \<subseteq> Bad S n \<union> (\<Union>i<N. Bad (L i) n)" using Bad_inter by force
      moreover have "Bad S n \<union> (\<Union>i<N. Bad (L i) n) \<in> sets M"
        using Bad_meas S_meas L_meas by measurable
      ultimately have "emeasure M (Bad A n) \<le> emeasure M (Bad S n \<union> (\<Union>i<N. Bad (L i) n))"
        using emeasure_mono by auto
      also have "... \<le> emeasure M (Bad S n) + emeasure M (\<Union>i<N. Bad (L i) n)"
        by (simp add: Bad_meas L_meas S_meas emeasure_subadditive countable_Un_Int(1))
      also have "... \<le> emeasure M (Bad S n) + (\<Sum>i<N. emeasure M (Bad (L i) n))"
        by (simp add: add_left_mono image_subset_iff Bad_meas[OF L_meas]
            emeasure_subadditive_finite[OF finite_lessThan[of N], where ?A = "\<lambda>i. Bad (L i) n"])
      also have "... \<le> ennreal e2 + ennreal e2"
        using SBad_small less_imp_le[OF *[OF `n > N2`]] by (rule add_mono)
      also have "... < e" using e2_def `e>0` by (simp del: ennreal_plus add: ennreal_plus[symmetric] ennreal_lessI)
      finally have "emeasure M (Bad A n) < e" by simp
    }
    then show "\<forall>\<^sub>F x in sequentially. emeasure M {xa \<in> (T ^^ x) --` A. local_time B x xa < k} < e"
      unfolding eventually_at_top_dense Bad_def by auto
  qed
qed

subsection {*The first return time*}

definition return_time_function::"'a set \<Rightarrow> ('a \<Rightarrow> nat)"
  where "return_time_function A x = (
    if (x \<in> recurrent_subset A) then (Inf {n::nat\<in>{1..}. (T^^n) x \<in> A})
    else 0)"

lemma return_time0:
  "(return_time_function A)-`{0} = UNIV - recurrent_subset A"
proof (auto)
  fix x
  assume *: "x \<in> recurrent_subset A" "return_time_function A x = 0"
  define K where "K = {n::nat\<in>{1..}. (T^^n) x \<in> A}"
  have **: "return_time_function A x = Inf K"
    using K_def return_time_function_def * by simp
  have "K \<noteq> {}" using K_def recurrent_subset_def * by auto
  moreover have "0 \<notin> K" using K_def by auto
  ultimately have "Inf K >0"
    by (metis (no_types, lifting) K_def One_nat_def atLeast_iff cInf_lessD mem_Collect_eq neq0_conv not_le zero_less_Suc)
  then have "return_time_function A x > 0" using ** by simp
  then show "False" using * by simp
next
  fix x
  assume "x \<notin> recurrent_subset A"
  then show "return_time_function A x = 0" using return_time_function_def by simp
qed

lemma return_time_n:
  assumes "A \<in> sets M"
  shows "(return_time_function A)-`{n+1} = return_partition A (n+1)"
proof
  show "return_time_function A -` {n + 1} \<subseteq> return_partition A (n + 1)"
  proof
    fix x
    assume *: "x \<in> return_time_function A -` {n + 1}"
    then have "return_time_function A x = n + 1" by simp
    then have "return_time_function A x \<noteq> 0" by simp
    then have rx: "x \<in> recurrent_subset A" using return_time_function_def by meson
    define K where "K = {i::nat\<in>{1..}. (T^^i) x \<in> A}"
    have "return_time_function A x = Inf K" using return_time_function_def rx K_def by auto
    then have "Inf K = n+1" using * by simp
    moreover have "K \<noteq> {}" using rx recurrent_subset_def K_def by auto
    ultimately have "n+1 \<in> K" using Inf_nat_def1[of K] by simp
    then have "(T^^(n+1))x \<in> A" using K_def by auto
    then have a: "x \<in> A \<inter> (T^^(n+1))--`A"
      unfolding vimage_restr_def using recurrent_subset_incl[of A]
      by (meson IntI assms rx sets.sets_into_space subsetCE vimage_eq)
    have "\<And>i. i\<in>{1..<n+1} \<Longrightarrow> i \<notin> K" using cInf_lower `Inf K = n+1` by force
    then have "\<And>i. i\<in>{1..<n+1} \<Longrightarrow> (T^^i) x \<notin> A" using K_def by force
    then have "\<And>i. i\<in>{1..<n+1} \<Longrightarrow> x \<notin> (T^^i)--`A" using vimage_restr_def by auto
    then have "x \<notin> (\<Union>i\<in>{1..<n+1}. (T^^i)--`A)" by auto
    then show "x \<in> return_partition A (n + 1)" using a return_partition_def by simp
  qed
  show "return_partition A (n + 1) \<subseteq> return_time_function A -` {n + 1}"
  proof
    fix x
    assume *: "x \<in> return_partition A (n + 1)"
    then have a: "x \<in> space M" unfolding return_partition_def using vimage_restr_def by blast
    define K where "K = {i::nat\<in>{1..}. (T^^i) x \<in> A}"
    have "n+1 \<in> K" using * K_def return_partition_def vimage_restr_def by force
    moreover have "\<And>i. i < n+1 \<Longrightarrow> i \<notin> K" using K_def * return_partition_def vimage_restr_def assms a by force
    ultimately have "Inf K = n+1" using Inf_nat_def0 by simp

    have "x \<in> recurrent_subset A" using * return_partition_basics(3)[OF assms] by auto
    then have "return_time_function A x = Inf K" using return_time_function_def K_def by simp
    then show "x \<in> return_time_function A -` {n + 1}" using `Inf K = n+1` by auto
  qed
qed

lemma return_time_function_meas [measurable]:
  assumes [measurable]: "A \<in> sets M"
    shows "return_time_function A \<in> measurable M (count_space UNIV)"
proof -
  have "(return_time_function A)-`{0} \<inter> space M = space M - recurrent_subset A"
    using return_time0 by blast
  then have *: "(return_time_function A)-`{0} \<inter> space M \<in> sets M"
    using recurrent_subset_meas[OF assms] by auto
  have "\<And>n. (return_time_function A)-`{n+1} \<in> sets M"
    using return_time_n[OF assms] return_partition_basics(1)[OF assms] by auto
  then have "\<And>n. n\<noteq>0 \<Longrightarrow> (return_time_function A)-`{n} \<in> sets M"
    by (metis Suc_eq_plus1 not0_implies_Suc)
  then have "\<And>n. n\<noteq>0 \<Longrightarrow> (return_time_function A)-`{n} \<inter> space M \<in> sets M"
    by auto
  then have "\<And>n. (return_time_function A)-`{n} \<inter> space M \<in> sets M" using * by metis
  then show ?thesis
    by (simp add: measurable_count_space_eq2_countable assms)
qed

definition first_entrance_set::"'a set \<Rightarrow> nat \<Rightarrow> 'a set"
  where "first_entrance_set A n = (T^^n) --` A - (\<Union> i<n. (T^^i)--`A)"

lemma first_entrance_meas [measurable]:
  assumes "A \<in> sets M"
    shows "first_entrance_set A n \<in> sets M"
unfolding first_entrance_set_def using T_vrestr_meas[OF assms] by measurable

lemma first_entrance_disjoint:
  "disjoint_family (first_entrance_set A)"
proof -
  have "first_entrance_set A = disjointed (\<lambda>i. (T^^i)--`A)"
    by (auto simp add: disjointed_def first_entrance_set_def)
  then show ?thesis by (simp add: disjoint_family_disjointed)
qed

lemma first_entrance_rec:
  assumes "A \<in> sets M"
  shows "first_entrance_set A (n+1) = T--`(first_entrance_set A n) - A"
proof -
  have A0: "A = (T^^0)--`A" by (auto simp add: assms vimage_restr_def)

  have "first_entrance_set A n = (T^^n) --` A - (\<Union> i<n. (T^^i)--`A)"
    using first_entrance_set_def by simp
  then have "T--`(first_entrance_set A n) = (T^^(n+1))--`A - (\<Union> i<n. (T^^(i+1))--`A)"
    using T_vrestr_composed(2) `A \<in> sets M` by simp
  then have *: "T--`(first_entrance_set A n) - A = (T^^(n+1))--`A - (A \<union> (\<Union> i<n. (T^^(i+1))--`A))"
    by blast
  have "(\<Union> i<n. (T^^(i+1))--`A) = (\<Union> j\<in>{1..<n+1}. (T^^j)--`A)"
    by (metis (mono_tags, lifting) UN_le_add_shift_strict SUP_cong)
  then have "A \<union> (\<Union> i<n. (T^^(i+1))--`A) = (\<Union> j\<in>{0..<n+1}. (T^^j)--`A)"
    by (metis A0 Un_commute atLeast0LessThan UN_le_eq_Un0_strict)
  then show ?thesis using * first_entrance_set_def by auto
qed

lemma return_time_rec:
  assumes "A \<in> sets M"
  shows "(return_time_function A)-`{n+1} = T--`(first_entrance_set A n) \<inter> A"
proof -
  have "return_partition A (n+1) = T--`(first_entrance_set A n) \<inter> A"
    unfolding return_partition_def first_entrance_set_def
    by (auto simp add: T_vrestr_composed[OF assms]) (auto simp add: less_Suc_eq_0_disj)
  then show ?thesis using return_time_n[OF assms] by simp
qed

subsection{*The induced map*}

definition induced_map::"'a set \<Rightarrow> ('a \<Rightarrow> 'a)"
  where "induced_map A = (\<lambda> x. (T^^(return_time_function A x)) x)"

lemma induced_map_stabilizes_A:
  "x \<in> A \<longleftrightarrow> induced_map A x \<in> A"
proof (rule equiv_neg)
  fix x
  assume "x \<in> A"
  show "induced_map A x \<in> A"
  proof (cases)
    assume "x \<notin> recurrent_subset A"
    then have "induced_map A x = x" using induced_map_def return_time_function_def by simp
    then show ?thesis using `x \<in> A` by simp
  next
    assume H: "\<not>(x \<notin> recurrent_subset A)"
    define K where "K = {n::nat\<in>{1..}. (T^^n) x \<in> A}"
    have "K \<noteq> {}" using H recurrent_subset_def K_def by blast
    moreover have "return_time_function A x = Inf K" using return_time_function_def K_def H by simp
    ultimately have "return_time_function A x \<in> K" using Inf_nat_def1 by simp
    then show ?thesis unfolding induced_map_def K_def by blast
  qed
next
  fix x
  assume "x \<notin> A"
  then have "x \<notin> recurrent_subset A" using recurrent_subset_def by simp
  then have "induced_map A x = x" using induced_map_def return_time_function_def by simp
  then show "induced_map A x \<notin> A" using `x \<notin> A` by simp
qed

lemma induced_map_iterates_stabilize_A:
  assumes "x \<in> A"
  shows "((induced_map A)^^n) x \<in> A"
proof (induction n)
  case 0
  show ?case using `x \<in> A` by auto
next
  case (Suc n)
  have "((induced_map A)^^(Suc n)) x = (induced_map A) (((induced_map A)^^n) x)" by auto
  then show ?case using Suc.IH induced_map_stabilizes_A by auto
qed

lemma induced_map_meas [measurable]:
  assumes A: "A \<in> sets M"
    shows "induced_map A \<in> measurable M M"
  unfolding induced_map_def
  by (rule measurable_compose_countable[OF Tn_meas return_time_function_meas[OF A]])

lemma induced_map_iterates:
  "((induced_map A)^^n) x = (T^^(\<Sum>i < n. return_time_function A ((induced_map A ^^i) x))) x"
proof (induction n)
  case 0
  show ?case by auto
next
  case (Suc n)
  have "((induced_map A)^^(n+1)) x = induced_map A (((induced_map A)^^n) x)" by (simp add: funpow_add)
  also have "... = (T^^(return_time_function A (((induced_map A)^^n) x))) (((induced_map A)^^n) x)"
    using induced_map_def by auto
  also have "... = (T^^(return_time_function A (((induced_map A)^^n) x))) ((T^^(\<Sum>i < n. return_time_function A ((induced_map A ^^i) x))) x)"
    using Suc.IH by auto
  also have "... = (T^^(return_time_function A (((induced_map A)^^n) x) + (\<Sum>i < n. return_time_function A ((induced_map A ^^i) x)))) x"
    by (simp add: funpow_add)
  also have "... = (T^^(\<Sum>i < Suc n. return_time_function A ((induced_map A ^^i) x))) x" by (simp add: add.commute)
  finally show ?case by simp
qed

lemma induced_map_stabilizes_recurrent_infty:
  assumes "x \<in> recurrent_subset_infty A" and [measurable]: "A \<in> sets M"
  shows "((induced_map A)^^n) x \<in> recurrent_subset A"
proof -
  have "x \<in> A" using assms(1) recurrent_subset_incl(2) by auto

  define R where "R = (\<Sum>i < n. return_time_function A ((induced_map A ^^i) x))"
  have *: "((induced_map A)^^n) x = (T^^R) x" unfolding R_def by (rule induced_map_iterates)
  moreover have "((induced_map A)^^n) x \<in> A"
    by (rule induced_map_iterates_stabilize_A, simp add: `x \<in> A`)
  ultimately have "(T^^R) x \<in> A" by simp
  have "x \<notin> (T^^R)-` (A - recurrent_subset A)"
    using assms(1) unfolding recurrent_subset_infty_def using `x \<in> A` by blast
  then have "(T^^R) x \<notin> (A - recurrent_subset A)" unfolding vimage_restr_def
    by (meson Diff_subset IntI `x \<in> A` assms(2) sets.sets_into_space subsetCE vimageI)
  then have "(T^^R) x \<in> recurrent_subset A" using `(T^^R) x \<in> A` by auto
  then show ?thesis using * by simp
qed

lemma induced_map_returns:
  assumes "x \<in> A"
  shows "((T^^n) x \<in> A) \<longleftrightarrow> (\<exists>N\<le>n. n = (\<Sum>i<N. return_time_function A ((induced_map A ^^ i) x)))"
proof
  assume "(T^^n) x \<in> A"
  {
    fix n
    have "\<And>y. y \<in> A \<Longrightarrow> (T^^n)y \<in> A \<Longrightarrow> \<exists>N\<le>n. n = (\<Sum>i<N. return_time_function A (((induced_map A)^^i) y))"
    proof (induction n rule: nat_less_induct)
      case (1 n)
      show "\<exists>N\<le>n. n = (\<Sum>i<N. return_time_function A (((induced_map A)^^i) y))"
      proof (cases)
        assume "n = 0"
        then show ?thesis by auto
      next
        assume "\<not>(n = 0)"
        then have "n > 0" by simp
        then have y_rec: "y \<in> recurrent_subset A" using `y \<in> A` `(T^^n) y \<in> A` recurrent_subset_def by auto
        then have *: "return_time_function A y > 0" by (metis DiffE insert_iff neq0_conv vimage_eq return_time0)
        define m where "m = return_time_function A y"
        have "m > 0" using * m_def by simp
        define K where "K = {t \<in> {1..}. (T ^^ t) y \<in> A}"
        have "n \<in> K" unfolding K_def using `n > 0` `(T^^n)y \<in> A` by simp
        then have "n \<ge> Inf K" by (simp add: cInf_lower)
        moreover have "m = Inf K" unfolding m_def K_def return_time_function_def using y_rec by simp
        ultimately have "n \<ge> m" by simp
        define z where "z = induced_map A y"
        have "z \<in> A" using `y \<in> A` induced_map_stabilizes_A z_def by simp
        have "z = (T^^m) y" using induced_map_def y_rec z_def m_def by auto
        then have "(T^^(n-m)) z = (T^^n) y" using `n \<ge> m` funpow_add[of "n-m" m T, symmetric]
          by (metis comp_apply le_add_diff_inverse2)
        then have "(T^^(n-m)) z \<in> A" using `(T^^n) y \<in> A` by simp
        moreover have "n-m < n" using `m > 0` `n > 0` by simp
        ultimately obtain N0 where "N0 \<le> n-m" "n-m = (\<Sum>i<N0. return_time_function A (((induced_map A)^^i) z))"
          using `z \<in> A` "1.IH" by blast
        then have "n-m = (\<Sum>i<N0. return_time_function A (((induced_map A)^^i) (induced_map A y)))"
          using z_def by auto
        moreover have "\<And>i. ((induced_map A)^^i) (induced_map A y) = ((induced_map A)^^(i+1)) y"
          by (metis Suc_eq_plus1 comp_apply funpow_Suc_right)
        ultimately have "n-m = (\<Sum>i<N0. return_time_function A (((induced_map A)^^(i+1)) y))"
          by simp
        then have "n-m = (\<Sum>i \<in> {1..<N0+1}. return_time_function A (((induced_map A)^^i) y))"
          using sum_shift_bounds_nat_ivl[of "\<lambda>i. return_time_function A (((induced_map A)^^i) y)", of 0, of 1, of N0, symmetric]
                atLeast0LessThan by auto
        moreover have "m = (\<Sum>i\<in>{0..<1}. return_time_function A (((induced_map A)^^i) y))" using m_def by simp
        ultimately have "n = (\<Sum>i\<in>{0..<1}. return_time_function A (((induced_map A)^^i) y))
          + (\<Sum>i \<in> {1..<N0+1}. return_time_function A (((induced_map A)^^i) y))" using `n \<ge> m` by simp
        then have "n = (\<Sum>i\<in>{0..<N0+1}. return_time_function A (((induced_map A)^^i) y))"
          using le_add2 sum_add_nat_ivl by blast
        moreover have "N0 + 1 \<le> n" using `N0 \<le> n-m` `n - m < n` by linarith
        ultimately show ?thesis by (metis atLeast0LessThan)
      qed
    qed
  }
  then show "\<exists>N\<le>n. n = (\<Sum>i<N. return_time_function A ((induced_map A ^^ i) x))"
    using `x \<in> A` `(T^^n) x \<in> A` by simp
next
  assume "\<exists>N\<le>n. n = (\<Sum>i<N. return_time_function A ((induced_map A ^^ i) x))"
  then obtain N where "n = (\<Sum>i<N. return_time_function A ((induced_map A ^^ i) x))" by blast
  then have "(T^^n) x = ((induced_map A)^^N) x" using induced_map_iterates[of N, of A, of x] by simp
  then show "(T^^n) x \<in> A" using `x \<in> A` induced_map_iterates_stabilize_A by auto
qed

text {*the next lemma does not hold in the qmpt category. For instance, the right translation
on $\mathbb{Z}$ is qmpt, but the induced map on $\mathbb{N}$ (again the right translation) is not,
since the measure of $\{0\}$ is nonzero, while its preimage, the empty set, has zero measure.*}

lemma (in conservative) induced_map_is_conservative:
  assumes A_meas: "A \<in> sets M"
  shows "conservative (restrict_space M A) (induced_map A)"
proof
  have "sigma_finite_measure M" by unfold_locales
  then have "sigma_finite_measure (restrict_space M A)"
    using sigma_finite_measure_restrict_space assms by auto
  then show "\<exists>Aa. countable Aa \<and> Aa \<subseteq> sets (restrict_space M A) \<and> \<Union>Aa = space (restrict_space M A)
    \<and> (\<forall>a\<in>Aa. emeasure (restrict_space M A) a \<noteq> \<infinity>)" using sigma_finite_measure_def by auto

  have imp: "\<And>B. (B \<in> sets M \<and> B \<subseteq> A \<and> emeasure M B > 0) \<Longrightarrow> (\<exists>N>0. emeasure M (((induced_map A)^^N)-`B \<inter> B) > 0)"
  proof -
    fix B
    assume assm: "B \<in> sets M \<and> B \<subseteq> A \<and> emeasure M B > 0"
    then have "B \<subseteq> A" by simp
    have inc: "(\<Union>n\<in>{1..}. (T^^n)-`B \<inter> B) \<subseteq> (\<Union>N\<in>{1..}. ((induced_map A)^^N)-` B \<inter> B)"
    proof
      fix x
      assume "x \<in> (\<Union>n\<in>{1..}. (T^^n)-`B \<inter> B)"
      then obtain n where "n\<in>{1..}" and *: "x \<in> (T^^n)-`B \<inter> B" by auto
      then have "n > 0" by auto
      have "x \<in> A" "(T^^n) x \<in> A" using * `B \<subseteq> A` by auto
      then obtain N where **: "n = (\<Sum>i<N. return_time_function A ((induced_map A ^^ i) x))"
        using induced_map_returns by auto
      then have "((induced_map A)^^N) x = (T^^n) x" using induced_map_iterates[of N, of A, of x] by simp
      then have "((induced_map A)^^N) x \<in> B" using * by simp
      then have "x \<in> ((induced_map A)^^N)-` B \<inter> B" using * by simp
      moreover have "N > 0" using ** `n > 0`
        by (metis leD lessThan_iff less_nat_zero_code neq0_conv sum.neutral_const sum_mono)
      ultimately show "x \<in> (\<Union>N\<in>{1..}. ((induced_map A)^^N)-` B \<inter> B)" by auto
    qed
    have B_meas: "B \<in> sets M" and B_pos: "emeasure M B > 0" using assm by auto
    obtain n where "n > 0" and pos: "emeasure M ((T^^n)-`B \<inter> B) > 0"
      using conservative[OF B_meas, OF B_pos] by auto
    then have "n \<in> {1..}" by auto

    have itB_meas: "\<And>i. ((induced_map A)^^i)-` B \<inter> B \<in> sets M"
      using B_meas measurable_compose_n[OF induced_map_meas[OF A_meas]] by (metis Int_assoc measurable_sets sets.Int sets.Int_space_eq1)
    then have "(\<Union>i\<in>{1..}. ((induced_map A)^^i)-` B \<inter> B) \<in> sets M" by measurable
    moreover have "(T^^n)-`B \<inter> B \<subseteq> (\<Union>i\<in>{1..}. ((induced_map A)^^i)-` B \<inter> B)" using inc `n \<in> {1..}` by force
    ultimately have "emeasure M (\<Union>i\<in>{1..}. ((induced_map A)^^i)-` B \<inter> B) > 0"
      by (metis (no_types, lifting) emeasure_eq_0 zero_less_iff_neq_zero pos)
    then have "emeasure M (\<Union>i\<in>{1..}. ((induced_map A)^^i)-` B \<inter> B) \<noteq> 0" by simp
    have "\<exists>i\<in>{1..}. emeasure M (((induced_map A)^^i)-` B \<inter> B) \<noteq> 0"
    proof (rule ccontr)
      assume "\<not>(\<exists>i\<in>{1..}. emeasure M (((induced_map A)^^i)-` B \<inter> B) \<noteq> 0)"
      then have a: "\<And>i. i \<in> {1..} \<Longrightarrow> ((induced_map A)^^i)-` B \<inter> B \<in> null_sets M"
        using itB_meas by auto
      have "(\<Union>i\<in>{1..}. ((induced_map A)^^i)-` B \<inter> B) \<in> null_sets M"
        by (rule null_sets_UN', simp_all add: a)
      then show "False" using `emeasure M (\<Union>i\<in>{1..}. ((induced_map A)^^i)-\` B \<inter> B) > 0` by auto
    qed
    then show "\<exists>N>0. emeasure M (((induced_map A)^^N)-` B \<inter> B) > 0"
      by (simp add: Bex_def less_eq_Suc_le zero_less_iff_neq_zero)
  qed

  define K where "K = {B. B \<in> sets M \<and> B \<subseteq> A}"
  have K_stable: "\<And>B. B \<in> K \<Longrightarrow> (induced_map A)-`B \<in> K"
  proof -
    fix B
    assume "B \<in> K"
    then have B_meas: "B \<in> sets M" and "B \<subseteq> A" unfolding K_def by auto
    then have a: "(induced_map A)-`B \<subseteq> A" using induced_map_stabilizes_A by auto
    then have "(induced_map A)-`B = (induced_map A)-`B \<inter> space M" using assms sets.sets_into_space by auto
    then have "(induced_map A)-`B \<in> sets M" using induced_map_meas[OF assms] B_meas by (metis vrestr_meas vrestr_of_set)
    then show "(induced_map A)-`B \<in> K" unfolding K_def using a by auto
  qed

  define K0 where "K0 = {B \<in> K. B \<in> null_sets M}"
  have K0_stable: "\<And>B. B \<in> K0 \<Longrightarrow> (induced_map A)-`B \<in> K0"
  proof -
    fix B assume "B \<in> K0"
    then have "B \<in> K" unfolding K0_def by simp
    then have a: "(induced_map A)-`B \<subseteq> A" and b: "(induced_map A)-`B \<in> sets M"
      using K_stable unfolding K_def by auto
    have B_meas [measurable]: "B \<in> sets M" using `B \<in> K` unfolding K_def by simp
    have B0: "B \<in> null_sets M" using `B \<in> K0` unfolding K0_def by simp

    have "(induced_map A)-`B \<subseteq> (\<Union>n. (T^^n)-`B)" unfolding induced_map_def by auto
    then have "(induced_map A)-`B \<subseteq> (\<Union>n. (T^^n)-`B \<inter> space M)"
      using b sets.sets_into_space by simp blast
    then have inc: "(induced_map A)-`B \<subseteq> (\<Union>n. (T^^n)--`B)" unfolding vimage_restr_def
      using sets.sets_into_space [OF B_meas] by simp
    have m [measurable]: "(T^^n)--`B \<in> sets M" for n using T_vrestr_meas(2)[OF B_meas] by simp
    then have m2 [measurable]: "(\<Union>n. (T^^n)--`B) \<in> sets M" by measurable

    have "(T^^n)--`B \<in> null_sets M" for n using B0 T_quasi_preserves_null(2)[OF B_meas] by simp
    then have "(\<Union>n. (T^^n)--`B) \<in> null_sets M" using null_sets_UN by auto
    then have "(induced_map A)-`B \<in> null_sets M" using null_sets_subset[OF _ b inc] by auto
    then show "(induced_map A)-`B \<in> K0" unfolding K0_def K_def by (simp add: a b)
  qed


  have *: "D \<in> null_sets M \<longleftrightarrow> D \<in> null_sets (restrict_space M A)" if "D\<in>K" for D
    using that unfolding K_def apply auto
    apply (metis assms emeasure_restrict_space null_setsD1 null_setsI sets.Int_space_eq2 sets_restrict_space_iff)
    by (metis assms emeasure_restrict_space null_setsD1 null_setsI sets.Int_space_eq2)

  show "induced_map A \<in> quasi_measure_preserving (restrict_space M A) (restrict_space M A)"
    unfolding quasi_measure_preserving_def
  proof (auto)
    have "induced_map A \<in> A \<rightarrow> A" using induced_map_stabilizes_A by auto
    then show a: "induced_map A \<in> measurable (restrict_space M A) (restrict_space M A)"
      using measurable_restrict_space3[where ?A = A and ?B = A and ?M = M and ?N = M] induced_map_meas[OF A_meas] by auto

    fix B assume H: "B \<in> sets (restrict_space M A)"
                    "induced_map A -`B \<inter> space (restrict_space M A) \<in> null_sets (restrict_space M A)"
    then have "B \<in> K" unfolding K_def by (metis assms mem_Collect_eq sets.Int_space_eq2 sets_restrict_space_iff)
    then have B_meas [measurable]: "B \<in> sets M" and B_incl: "B \<subseteq> A" unfolding K_def by auto
    have "induced_map A -`B \<in> K" using K_stable `B \<in> K` by auto
    then have B2_meas: "induced_map A -`B \<in> sets M" and B2_incl: "induced_map A -`B \<subseteq> A"
      unfolding K_def by auto
    have "induced_map A -` B = induced_map A -`B \<inter> space (restrict_space M A)"
      using B2_incl by (simp add: Int_absorb2 assms space_restrict_space)
    then have "induced_map A -` B \<in> null_sets (restrict_space M A)" using H(2) by simp
    then have "induced_map A -` B \<in> K0" unfolding K0_def using `induced_map A -\`B \<in> K` * by auto
    {
      fix n
      have *: "((induced_map A)^^(n+1))-`B \<in> K0"
      proof (induction n)
        case (Suc n)
        have "((induced_map A)^^(Suc n+1))-`B = (induced_map A)-`(((induced_map A)^^(n+1))-` B)"
          by (metis Suc_eq_plus1 funpow_Suc_right vimage_comp)
        then show ?case by (metis Suc.IH K0_stable)
      qed (auto simp add: `induced_map A -\` B \<in> K0`)
      have **: "((induced_map A)^^(n+1))-` B \<in> sets M" using * K0_def K_def by auto
      have "((induced_map A)^^(n+1))-` B \<inter> B \<in> null_sets M"
        apply (rule null_sets_subset[of "((induced_map A)^^(n+1))-`B"])
        using * unfolding K0_def apply simp
        using ** by auto
    }
    then have "((induced_map A)^^n)-` B \<inter> B \<in> null_sets M" if "n>0" for n
      using that by (metis Suc_eq_plus1 neq0_conv not0_implies_Suc)
    then have "B \<in> null_sets M" using imp B_incl B_meas zero_less_iff_neq_zero inf.strict_order_iff
      by (metis null_setsD1 null_setsI)
    then show "B \<in> null_sets (restrict_space M A)" using * `B \<in> K` by auto
  next
    fix B assume H: "B \<in> sets (restrict_space M A)"
                    "B \<in> null_sets (restrict_space M A)"
    then have "B \<in> K" unfolding K_def by (metis assms mem_Collect_eq sets.Int_space_eq2 sets_restrict_space_iff)
    then have B_meas [measurable]: "B \<in> sets M" and B_incl: "B \<subseteq> A" unfolding K_def by auto
    have "B \<in> null_sets M" using * H(2) `B \<in> K` by simp
    then have "B \<in> K0" unfolding K0_def using `B \<in> K` by simp
    then have inK: "(induced_map A)-`B \<in> K0" using K0_stable by auto
    then have inA: "(induced_map A)-`B \<subseteq> A" unfolding K0_def K_def by auto
    then have "(induced_map A)-`B = (induced_map A)-`B \<inter> space (restrict_space M A)"
      by (simp add: Int_absorb2 assms space_restrict_space2)
    then show "induced_map A -` B \<inter> space (restrict_space M A) \<in> null_sets (restrict_space M A)"
      using * inK unfolding K0_def by auto
  qed

  fix B
  assume B_measA: "B \<in> sets (restrict_space M A)" and B_posA: "0 < emeasure (restrict_space M A) B"
  then have B_meas: "B \<in> sets M" by (metis assms sets.Int_space_eq2 sets_restrict_space_iff)
  have B_incl: "B \<subseteq> A" by (metis B_measA assms sets.Int_space_eq2 sets_restrict_space_iff)
  then have B_pos: "0 < emeasure M B" using B_posA by (simp add: assms emeasure_restrict_space)
  obtain N where "N>0" "emeasure M (((induced_map A)^^N)-`B \<inter> B) > 0" using imp B_meas B_incl B_pos by auto
  then have "emeasure (restrict_space M A) ((induced_map A ^^ N) -` B \<inter> B) > 0"
    using assms emeasure_restrict_space by (metis B_incl Int_lower2 sets.Int_space_eq2 subset_trans)
  then show "\<exists>n>0. 0 < emeasure (restrict_space M A) ((induced_map A ^^ n) -` B \<inter> B)"
    using `N > 0` by auto
qed

lemma (in conservative_mpt) induced_map_measure_preserving_aux:
  assumes A_meas [measurable]: "A \<in> sets M"
      and W_meas [measurable]: "W \<in> sets M"
      and incl: "W \<subseteq> A"
      and fin: "emeasure M W < \<infinity>"
  shows "emeasure M ((induced_map A)--`W) = emeasure M W"
proof -
  have "W \<subseteq> space M" using W_meas
    using sets.sets_into_space by blast
  define BW where "BW = (\<lambda>n. (first_entrance_set A n) \<inter> (T^^n)--`W)"
  define DW where "DW = (\<lambda>n. (return_time_function A)-` {n} \<inter> (induced_map A)--`W)"

  have "\<And>n. DW n = (return_time_function A)-` {n} \<inter> space M \<inter> (induced_map A)--`W"
    using vimage_restr_def DW_def by auto
  then have DW_meas [measurable]: "\<And>n. DW n \<in> sets M" by auto
  have disj_DW: "disjoint_family (\<lambda>n. DW n)" using DW_def disjoint_family_on_def by blast
  then have disj_DW2: "disjoint_family (\<lambda>n. DW (n+1))" by (simp add: disjoint_family_on_def)

  have "(\<Union>n. DW n) = DW 0 \<union> (\<Union>n. DW (n+1))" by (auto) (metis not0_implies_Suc)
  moreover have "(DW 0) \<inter> (\<Union>n. DW (n+1)) = {}"
    by (auto) (metis IntI Suc_neq_Zero UNIV_I empty_iff disj_DW disjoint_family_on_def)
  ultimately have *: "emeasure M (\<Union>n. DW n) = emeasure M (DW 0) + emeasure M (\<Union>n. DW (n+1))"
    by (simp add: DW_meas countable_Un_Int(1) plus_emeasure)

  have "(T^^0)--`W = W" by (auto simp add: assms vimage_restr_def)
  moreover have "DW 0 = (return_time_function A)-` {0} \<inter> (T^^0)--`W"
    unfolding DW_def induced_map_def vimage_restr_def return_time_function_def
    apply (auto simp add: return_time0[of A]) using sets.sets_into_space[OF W_meas] by auto
  ultimately have "DW 0 = (return_time_function A)-` {0} \<inter> W" by simp
  then have "DW 0 = W - recurrent_subset A" using return_time0 by blast
  then have "DW 0 \<subseteq> A - recurrent_subset A" using incl by blast
  then have "DW 0 \<in> null_sets M" by (metis A_meas DW_meas null_sets_subset Poincare_recurrence_thm(1))
  then have "emeasure M (DW 0) = 0" by auto
  have "(induced_map A)--`W = (\<Union>n. DW n)" using DW_def by blast
  then have "emeasure M ((induced_map A)--`W) = emeasure M (\<Union>n. DW n)" by simp
  also have "... = emeasure M (\<Union>n. DW (n+1))" using * `emeasure M (DW 0) = 0` by simp
  also have "... = (\<Sum>n. emeasure M (DW (n+1)))"
    apply (rule suminf_emeasure[symmetric]) using disj_DW2 by auto
  finally have m: "emeasure M ((induced_map A)--`W) = (\<Sum>n. emeasure M (DW (n+1)))" by simp
  moreover have "summable (\<lambda>n. emeasure M (DW (n+1)))" by simp
  ultimately have lim: "(\<lambda>N. (\<Sum> n\<in>{..<N}. emeasure M (DW (n+1)))) \<longlonglongrightarrow> emeasure M ((induced_map A)--`W)"
    by (simp add: summable_LIMSEQ)

  have BW_meas [measurable]: "\<And>n. BW n \<in> sets M" unfolding BW_def by simp
  have *: "\<And>n. T--`(BW n) - A = BW (n+1)"
  proof -
    fix n
    have "T--`(BW n) = T--`(first_entrance_set A n) \<inter> (T^^(n+1))--`W"
      unfolding BW_def by (simp add: assms(2) T_vrestr_composed(2))
    then have "T--`(BW n) - A = (T--`(first_entrance_set A n) - A) \<inter> (T^^(n+1))--`W"
      by blast
    then have "T--`(BW n) - A = first_entrance_set A (n+1) \<inter> (T^^(n+1))--`W"
      using first_entrance_rec[OF A_meas] by simp
    then show "T--`(BW n) - A = BW (n+1)" using BW_def by simp
  qed

  have **: "\<And>n. DW (n+1) = T--`(BW n) \<inter> A"
  proof -
    fix n
    have "T--`(BW n) = T--`(first_entrance_set A n) \<inter> (T^^(n+1))--`W"
      unfolding BW_def by (simp add: assms(2) T_vrestr_composed(2))
    then have "T--`(BW n) \<inter> A = (T--`(first_entrance_set A n) \<inter> A) \<inter> (T^^(n+1))--`W"
      by blast
    then have *: "T--`(BW n) \<inter> A = (return_time_function A)-`{n+1} \<inter> (T^^(n+1))--`W"
      using return_time_rec[OF A_meas] by simp

    have "DW (n+1) = (return_time_function A)-`{n+1} \<inter> (induced_map A)-`W"
      using DW_def `W \<subseteq> space M` A_meas return_time_rec vimage_restr_def by auto
    also have "... = (return_time_function A)-`{n+1} \<inter> (T^^(n+1))-`W"
      by (auto simp add: induced_map_def)
    also have "... = (return_time_function A)-`{n+1} \<inter> (T^^(n+1))--`W"
      using `W \<subseteq> space M` A_meas return_time_rec vimage_restr_def by auto
    finally show "DW (n+1) = T--`(BW n) \<inter> A" using * by simp
  qed

  have "emeasure M W = (\<Sum> n\<in>{..<N}. emeasure M (DW (n+1))) + emeasure M (BW N)" for N
  proof (induction N)
    case 0
    have "(T^^0)--`A = A" by (auto simp add: A_meas vimage_restr_def)
    moreover have "(T^^0)--`W = W" by (auto simp add: assms vimage_restr_def)
    ultimately have "BW 0 = W" unfolding BW_def first_entrance_set_def using incl by blast
    then show ?case by simp
  next
    case (Suc N)
    have "T--`(BW N) = BW (N+1) \<union> DW (N+1)" using * ** by blast
    moreover have "BW (N+1) \<inter> DW (N+1) = {}" using * ** by blast
    ultimately have "emeasure M (T--`(BW N)) = emeasure M (BW (N+1)) + emeasure M (DW (N+1))"
      using DW_meas BW_meas plus_emeasure[of "BW (N+1)"] by simp
    then have "emeasure M (BW N) = emeasure M (BW (N+1)) + emeasure M (DW (N+1))"
      using T_vrestr_same_emeasure(1) BW_meas by auto
    then have "(\<Sum> n\<in>{..<N}. emeasure M (DW (n+1))) + emeasure M (BW N)
                = (\<Sum> n\<in>{..<N+1}. emeasure M (DW (n+1))) + emeasure M (BW (N+1))"
      by (simp add: add.commute add.left_commute)
    then show ?case using Suc.IH by simp
  qed
  moreover
  have "(\<lambda>N. emeasure M (BW N)) \<longlonglongrightarrow> 0"
  proof -
    define C where "C = (\<lambda>N. {x \<in> (T^^N)--`W. local_time A N x < 1})"
    have "\<And>N. BW N \<subseteq> C N"
      unfolding BW_def C_def local_time_def first_entrance_set_def by (auto simp add: A_meas vimage_restr_def)
    moreover have [measurable]:"C N \<in> sets M" for N
    proof -
      have "C N = (T^^N)--`W \<inter> ((local_time A N)-`{0} \<inter> space M)"
        using vimage_restr_def A_meas C_def by blast
      then show "C N \<in> sets M" by simp
    qed
    ultimately have a: "\<And>N. emeasure M (BW N) \<le> emeasure M (C N)"
      using emeasure_mono by blast
    have b: "\<And>N. emeasure M (BW N) \<ge> 0" by auto
    have i: "W \<subseteq> (T^^0)--`A" using incl vimage_restr_def A_meas by auto
    have "(\<lambda>N. emeasure M (C N)) \<longlonglongrightarrow> 0" unfolding C_def
      by (rule local_time_unbounded2[OF W_meas, OF fin, OF i, of 1])
    then show "(\<lambda>N. emeasure M (BW N)) \<longlonglongrightarrow> 0"
      using tendsto_sandwich[of "\<lambda>_. 0", of "\<lambda>N. emeasure M (BW N)", of sequentially, of "\<lambda>N. emeasure M (C N)", of 0]
        a b by auto
  qed
  then have "(\<lambda>N. (\<Sum> n\<in>{..<N}. emeasure M (DW (n+1))) + emeasure M (BW N)) \<longlonglongrightarrow> emeasure M (induced_map A --` W) + 0"
    using lim by (intro tendsto_add) auto
  ultimately show ?thesis
    by (auto intro: LIMSEQ_unique LIMSEQ_const_iff)
qed

lemma (in conservative_mpt) induced_map_measure_preserving:
  assumes A_meas [measurable]: "A \<in> sets M"
      and W_meas [measurable]: "W \<in> sets M"
  shows "emeasure M ((induced_map A)--`W) = emeasure M W"
proof -
  define WA where "WA = W \<inter> A"
  have WA_meas [measurable]: "WA \<in> sets M" "WA \<subseteq> A" using WA_def by auto
  have WAi_meas [measurable]: "(induced_map A)--`WA \<in> sets M" by simp
  have a: "emeasure M WA = emeasure M ((induced_map A)--`WA)"
  proof (cases)
    assume "emeasure M WA < \<infinity>"
    then show ?thesis using induced_map_measure_preserving_aux[OF A_meas, OF `WA \<in> sets M`, OF `WA \<subseteq> A`] by simp
  next
    assume "\<not>(emeasure M WA < \<infinity>)"
    then have "emeasure M WA = \<infinity>" by (simp add: less_top[symmetric])
    {
      fix C::real
      obtain Z where "Z \<in> sets M" "Z \<subseteq> WA" "emeasure M Z < \<infinity>" "emeasure M Z > C"
        by (blast intro: `emeasure M WA = \<infinity>` WA_meas approx_PInf_emeasure_with_finite)
      have "Z \<subseteq> A" using `Z \<subseteq> WA` WA_def by simp
      have "C < emeasure M Z" using `emeasure M Z > C` by simp
      also have "... = emeasure M ((induced_map A)--`Z)"
        using induced_map_measure_preserving_aux[OF A_meas, OF `Z \<in> sets M`, OF `Z \<subseteq> A`] `emeasure M Z < \<infinity>` by simp
      also have "... \<le> emeasure M ((induced_map A)--`WA)"
        apply(rule emeasure_mono) using `Z \<subseteq> WA` vrestr_inclusion by auto
      finally have "emeasure M ((induced_map A)--`WA) > C" by simp
    }
    then have "emeasure M ((induced_map A)--`WA) = \<infinity>"
      by (cases "emeasure M ((induced_map A)--`WA)") auto
    then show ?thesis using `emeasure M WA = \<infinity>` by simp
  qed
  define WB where "WB = W - WA"
  have WB_meas [measurable]: "WB \<in> sets M" unfolding WB_def by simp
  have WBi_meas [measurable]: "(induced_map A)--`WB \<in> sets M" by simp
  have "WB \<inter> A = {}" unfolding WB_def WA_def by auto
  moreover have id: "\<And>x. x \<notin> A \<Longrightarrow> (induced_map A x) = x" unfolding induced_map_def return_time_function_def
    apply (auto) using recurrent_subset_incl by auto
  have "(induced_map A)-`WB = WB"
  proof
    show "WB \<subseteq> induced_map A -` WB" using id `WB \<inter> A = {}` by auto
    show "induced_map A -` WB \<subseteq> WB"
    proof
      fix x
      assume "x \<in> induced_map A -` WB"
      then have a: "induced_map A x \<in> WB" by simp
      then have "induced_map A x \<notin> A" using `WB \<inter> A = {}` by auto
      then have "x \<notin> A" using induced_map_stabilizes_A by auto
      then have "induced_map A x = x" using id by simp
      then show "x \<in> WB" using a by simp
    qed
  qed
  then have "(induced_map A)--`WB = WB" by (simp add: vimage_restr_def `WB \<in> sets M`)
  then have b: "emeasure M ((induced_map A)--`WB) = emeasure M WB" by simp

  have "W = WA \<union> WB" "WA \<inter> WB = {}" using WA_def WB_def by auto
  have *: "emeasure M W = emeasure M WA + emeasure M WB"
    by (subst `W = WA \<union> WB`, rule plus_emeasure[symmetric], auto simp add: `WA \<inter> WB = {}`)

  have W_AUB: "(induced_map A)--`W = (induced_map A)--`WA \<union> (induced_map A)--`WB"
    using `W = WA \<union> WB` by auto
  have W_AIB: "(induced_map A)--`WA \<inter> (induced_map A)--`WB = {}"
    by (metis `WA \<inter> WB = {}` vrestr_empty vrestr_intersec)
  have **: "emeasure M ((induced_map A)--`W) = emeasure M ((induced_map A)--`WA) + emeasure M ((induced_map A)--`WB)"
    by (subst W_AUB, rule plus_emeasure[symmetric], auto simp add: W_AIB)

  show ?thesis using a b * ** by simp
qed

theorem (in conservative_mpt) induced_map_is_conservative_mpt:
  assumes "A \<in> sets M"
  shows "conservative_mpt (restrict_space M A) (induced_map A)"
unfolding conservative_mpt_def
proof
  show *: "conservative (restrict_space M A) (induced_map A)" using induced_map_is_conservative[OF assms] by auto
  show "mpt (restrict_space M A) (induced_map A)" unfolding mpt_def mpt_axioms_def
  proof
    show "qmpt (restrict_space M A) (induced_map A)" using * conservative_def by auto
    then have meas: "(induced_map A) \<in> measurable (restrict_space M A) (restrict_space M A)"
      unfolding qmpt_def qmpt_axioms_def quasi_measure_preserving_def by auto
    moreover have "\<And>B. B \<in> sets (restrict_space M A) \<Longrightarrow>
        emeasure (restrict_space M A) ((induced_map A) -`B \<inter> space (restrict_space M A)) = emeasure (restrict_space M A) B"
    proof -
      have s: "space (restrict_space M A) = A" using assms space_restrict_space2 by auto
      have i: "\<And>D. D \<in> sets M \<and> D \<subseteq> A \<Longrightarrow> emeasure (restrict_space M A) D = emeasure M D"
        using assms by (simp add: emeasure_restrict_space)
      have j: "\<And>D. D \<in> sets (restrict_space M A) \<longleftrightarrow> (D \<in> sets M \<and> D \<subseteq> A)" using assms
        by (metis sets.Int_space_eq2 sets_restrict_space_iff)
      fix B
      assume a: "B \<in> sets (restrict_space M A)"
      then have B_meas: "B \<in> sets M" using j by auto
      then have first: "emeasure (restrict_space M A) B = emeasure M B" using i j a by auto
      have incl: "(induced_map A) -`B \<subseteq> A" using j a induced_map_stabilizes_A assms by auto
      then have eq: "(induced_map A) -`B \<inter> space (restrict_space M A) = (induced_map A) --`B"
        unfolding vimage_restr_def s using assms sets.sets_into_space
        by (metis a inf.orderE j meas measurable_sets s)
      then have "emeasure M B = emeasure M ((induced_map A) -`B \<inter> space (restrict_space M A))"
        using induced_map_measure_preserving a j assms by auto
      also have "... = emeasure (restrict_space M A) ((induced_map A) -`B \<inter> space (restrict_space M A))"
        using incl eq B_meas induced_map_meas[OF assms] assms i j
        by (metis emeasure_restrict_space inf.orderE s space_restrict_space)
      finally show "emeasure (restrict_space M A) ((induced_map A) -`B \<inter> space (restrict_space M A))
                    = emeasure (restrict_space M A) B"
        using first by auto
    qed
    ultimately show "induced_map A \<in> measure_preserving (restrict_space M A) (restrict_space M A)"
      unfolding measure_preserving_def by auto
  qed
qed

theorem (in fmpt) induced_map_is_fmpt:
  assumes "A \<in> sets M"
  shows "fmpt (restrict_space M A) (induced_map A)"
unfolding fmpt_def
proof -
  have "conservative_mpt (restrict_space M A) (induced_map A)" using induced_map_is_conservative_mpt[OF assms] by simp
  then have "mpt (restrict_space M A) (induced_map A)" using conservative_mpt_def by auto
  moreover have "finite_measure (restrict_space M A)" by (simp add: assms finite_measureI finite_measure_restrict_space)
  ultimately show "mpt (restrict_space M A) (induced_map A) \<and> finite_measure (restrict_space M A)" by simp
qed

lemma (in conservative) induced_map_recurrent_is_typical:
  assumes A_meas [measurable]: "A \<in> sets M"
  shows "AE z in (restrict_space M A). z \<in> recurrent_subset A"
        "AE z in (restrict_space M A). z \<in> recurrent_subset_infty A"
proof -
  have [measurable]: "recurrent_subset A \<in> sets M" using recurrent_subset_meas[OF A_meas] by auto
  then have [measurable]: "recurrent_subset A \<in> sets (restrict_space M A)" using recurrent_subset_incl(1)[of A]
    by (metis (no_types, lifting) A_meas sets_restrict_space_iff space_restrict_space space_restrict_space2)

  have "emeasure (restrict_space M A) (space (restrict_space M A) - recurrent_subset A) = emeasure (restrict_space M A) (A - recurrent_subset A)"
    by (metis (no_types, lifting) A_meas space_restrict_space2)
  also have "... = emeasure M (A - recurrent_subset A)"
    apply (rule emeasure_restrict_space) using A_meas by auto
  also have "... = 0" using Poincare_recurrence_thm[OF A_meas] by auto
  finally have "space (restrict_space M A) - recurrent_subset A \<in> null_sets (restrict_space M A)" by auto
  then show "AE z in (restrict_space M A). z \<in> recurrent_subset A"
      by (metis (no_types, lifting) DiffI eventually_ae_filter mem_Collect_eq subsetI)

  have [measurable]: "recurrent_subset_infty A \<in> sets M" using recurrent_subset_meas[OF A_meas] by auto
  then have [measurable]: "recurrent_subset_infty A \<in> sets (restrict_space M A)" using recurrent_subset_incl(2)[of A]
    by (metis (no_types, lifting) A_meas sets_restrict_space_iff space_restrict_space space_restrict_space2)

  have "emeasure (restrict_space M A) (space (restrict_space M A) - recurrent_subset_infty A) = emeasure (restrict_space M A) (A - recurrent_subset_infty A)"
    by (metis (no_types, lifting) A_meas space_restrict_space2)
  also have "... = emeasure M (A - recurrent_subset_infty A)"
    apply (rule emeasure_restrict_space) using A_meas by auto
  also have "... = 0" using Poincare_recurrence_thm[OF A_meas] by auto
  finally have "space (restrict_space M A) - recurrent_subset_infty A \<in> null_sets (restrict_space M A)" by auto
  then show "AE z in (restrict_space M A). z \<in> recurrent_subset_infty A"
    by (metis (no_types, lifting) DiffI eventually_ae_filter mem_Collect_eq subsetI)
qed



subsection {* Kac's theorem, and variants *}

text {* Kac's theorem states that, for conservative maps, the integral of the return time
to a subset $A$ is equal to the measure of the space if the dynamics is ergodic, or of the
space seen by $A$ in the general case.

This result generalizes to any induced function, not just the return time. *}

definition induced_function::"'a set \<Rightarrow> ('a \<Rightarrow> 'b::comm_monoid_add) \<Rightarrow> ('a \<Rightarrow> 'b)"
  where "induced_function A f = (\<lambda>x. (\<Sum>i\<in>{..< return_time_function A x}. f((T^^i) x)))"

lemma induced_function_support:
  fixes f::"'a \<Rightarrow> ennreal"
  shows "\<And>y. induced_function A f y = induced_function A f y * indicator ((return_time_function A)-`{1..}) y"
by (auto simp add: induced_function_def indicator_def not_less_eq_eq)

lemma induced_function_meas_ennreal [measurable]:
  fixes f::"'a \<Rightarrow> ennreal"
  assumes [measurable]: "f \<in> borel_measurable M"
          "A \<in> sets M"
  shows "induced_function A f \<in> borel_measurable M"
unfolding induced_function_def by simp

lemma induced_function_meas_real [measurable]:
  fixes f::"'a \<Rightarrow> real"
  assumes [measurable]: "f \<in> borel_measurable M"
          "A \<in> sets M"
  shows "induced_function A f \<in> borel_measurable M"
unfolding induced_function_def by simp

text{* The next lemma is very simple (just a change of variables to reorder
the indices in the double sum). However, the proof I give is very tedious:
infinite sums on proper subsets are not handled well, hence I use integrals
on products of discrete spaces instead, and go back and forth between the two
notions -- maybe there are better suited tools in the library, but I could
not locate them... *}

lemma kac_series_aux:
  fixes d:: "nat \<Rightarrow> nat \<Rightarrow> ennreal"
  shows "(\<Sum>n. (\<Sum>i\<le>n. d i n)) = (\<Sum>n. d 0 n) + (\<Sum>n. (\<Sum>i. d (i+1) (n+1+i)))"
    (is "_ = ?R")
proof -
  define g where "g = (\<lambda>(i,n). (i+(1::nat), n+1+i))"
  define U where "U = {(i,n). (i>(0::nat)) \<and> (n\<ge>i)}"
  have a: "range g = U"
  proof
    show "U \<subseteq> range g"
    proof
      fix x assume "x \<in> U"
      then obtain i n where "x=(i,n)" "i>0" "n\<ge>i" using U_def by blast
      then have "x = g (i-1, n-i)" using g_def by auto
      then show "x \<in> range g" by simp
    qed
  qed (auto simp add: g_def U_def)
  moreover have "inj g" by (auto simp add: g_def inj_on_def)
  ultimately have bij: "bij_betw g UNIV U" using bij_betw_def by auto

  define e where "e = (\<lambda> (i,j). d i j)"
  have pos: "\<And>x. e x \<ge> 0" using e_def by auto
  have "(\<Sum>n. (\<Sum>i. d (i+1) (n+1+i))) = (\<Sum>n. (\<Sum>i. e(i+1, n+1+i)))" using e_def by simp
  also have "... = \<integral>\<^sup>+n. \<integral>\<^sup>+i. e (i+1, n+1+i) \<partial>count_space UNIV \<partial>count_space UNIV"
    using pos nn_integral_count_space_nat suminf_0_le by auto
  also have "... = (\<integral>\<^sup>+(i,n). e (i+1, n+1+i) \<partial>count_space UNIV)"
    using nn_integral_snd_count_space[of "\<lambda>(i,n). e(i+1, n+1+i)"] by auto
  also have "... = (\<integral>\<^sup>+x. e (g x) \<partial>count_space UNIV)"
    using g_def by (simp add: prod.case_distrib)
  also have "... = (\<integral>\<^sup>+y \<in> U. e y \<partial>count_space UNIV)"
    using nn_integral_count_compose_bij[OF bij] by simp
  finally have *: "(\<Sum>n. (\<Sum>i. d (i+1) (n+1+i))) = (\<integral>\<^sup>+y \<in> U. e y \<partial>count_space UNIV)"
    by simp

  define V where "V = {((i::nat),(n::nat)). i = 0}"
  have i: "\<And>i n. e (i, n) * indicator {0} i = e (i, n) * indicator V (i, n)"
    by (auto simp add: indicator_def V_def)
  {
    fix n::nat
    have "finite {0}" by simp
    have "(\<integral>\<^sup>+i. e (i, n) \<partial>count_space {0}) = e (0, n)"
      using nn_integral_count_space_finite[OF `finite {0}`, where ?f="\<lambda>i. e (i, n)"]
      by (simp add: max.absorb2 pos)
    moreover have "(\<integral>\<^sup>+i \<in> {0}. e (i, n) \<partial>count_space UNIV) = (\<integral>\<^sup>+i. e (i, n) \<partial>count_space {0})"
      using nn_integral_count_space_indicator[of "{0}", of "\<lambda>i. e(i, n)"] by simp
    ultimately have "d 0 n = (\<integral>\<^sup>+i \<in> {0}. e (i, n) \<partial>count_space UNIV)" using e_def by simp
  }
  then have "(\<Sum>n. d 0 n) = (\<Sum>n. (\<integral>\<^sup>+i. e (i, n) * indicator {0} i \<partial>count_space UNIV))"
    by simp
  also have "... = (\<integral>\<^sup>+n. (\<integral>\<^sup>+i. e (i, n) * indicator {0} i \<partial>count_space UNIV) \<partial>count_space UNIV)"
    by (simp add: nn_integral_count_space_nat)
  also have "... = (\<integral>\<^sup>+(i,n). e (i, n) * indicator {0} i \<partial>count_space UNIV)"
    using nn_integral_snd_count_space[of "\<lambda> (i,n). e(i,n) * indicator {0} i"] by auto
  also have "... = (\<integral>\<^sup>+(i,n). e (i, n) * indicator V (i,n) \<partial>count_space UNIV)"
    by (metis i)
  finally have "(\<Sum>n. d 0 n) = (\<integral>\<^sup>+y \<in> V. e y \<partial>count_space UNIV)"
    by (simp add: split_def)

  then have "?R = (\<integral>\<^sup>+y \<in> V. e y \<partial>count_space UNIV) + (\<integral>\<^sup>+y \<in> U. e y \<partial>count_space UNIV)"
    using * by simp
  also have "... = (\<integral>\<^sup>+y \<in> V \<union> U. e y \<partial>count_space UNIV)"
    by (rule nn_integral_disjoint_pair_countspace[symmetric], auto simp add: U_def V_def)
  also have "... = (\<integral>\<^sup>+(i, n). e (i, n) * indicator {..n} i \<partial>count_space UNIV)"
    by (rule nn_integral_cong, auto simp add: indicator_def V_def U_def pos, meson)
  also have "... = (\<integral>\<^sup>+n. (\<integral>\<^sup>+i. e (i, n) * indicator {..n} i \<partial>count_space UNIV)\<partial>count_space UNIV)"
    using nn_integral_snd_count_space[of "\<lambda>(i,n). e(i,n) * indicator {..n} i"] by auto
  also have "... = (\<Sum>n. (\<Sum>i. e (i, n) * indicator {..n} i))"
    using pos nn_integral_count_space_nat suminf_0_le by auto
  moreover have "\<And>n. (\<Sum>i. e (i, n) * indicator {..n} i) = (\<Sum>i\<le>n. e (i, n))"
  proof -
    fix n::nat
    have "finite {..n}" by simp
    moreover have "\<And>i. i \<notin> {..n} \<Longrightarrow> e (i,n) * indicator {..n} i = 0" using indicator_def by simp
    then have "(\<Sum>i. e (i,n) * indicator {..n} i) = (\<Sum>i \<in> {..n} . e (i, n) * indicator {..n} i)"
      by (meson calculation suminf_finite)
    moreover have "\<And>i. i \<in> {..n} \<Longrightarrow> e (i, n) * indicator {..n} i = e (i, n)" using indicator_def by auto
    ultimately show "(\<Sum>i. e (i, n) * indicator {..n} i) = (\<Sum>i\<le>n. e (i, n))" by simp
  qed
  ultimately show ?thesis using e_def by simp
qed

end

context conservative_mpt begin

lemma induced_function_nn_integral_aux:
  fixes f::"'a \<Rightarrow> ennreal"
  assumes A_meas [measurable]: "A \<in> sets M"
      and f_meas [measurable]: "f \<in> borel_measurable M"
      and f_bound: "\<And>x. f x \<le> ennreal C" "0 \<le> C"
      and f_supp: "emeasure M {x \<in> space M. f x > 0} < \<infinity>"
  shows "(\<integral>\<^sup>+y. induced_function A f y \<partial>M) = (\<integral>\<^sup>+ x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M)"
proof -
  define B where "B = (\<lambda>n. first_entrance_set A n)"
  have B_meas [measurable]: "\<And>n. B n \<in> sets M" by (simp add: B_def)
  then have B2 [measurable]: "(\<Union>n. B (n+1)) \<in> sets M" by measurable

  have *: "B = disjointed (\<lambda>i. (T^^i)--`A)"
    by (auto simp add: B_def disjointed_def first_entrance_set_def)
  then have "disjoint_family B" by (simp add: disjoint_family_disjointed)

  have "(\<Union>n. (T^^n)--`A) = (\<Union>n. disjointed (\<lambda>i. (T^^i)--`A) n)" by (simp add: UN_disjointed_eq)
  then have "(\<Union>n. (T^^n)--`A) = (\<Union>n. B n)" using * by simp
  then have "(\<Union>n. (T^^n)--`A) = B 0 \<union> (\<Union>n. B (n+1))" by (auto) (metis not0_implies_Suc)
  then have "(\<integral>\<^sup>+ x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M) = (\<integral>\<^sup>+ x \<in> (B 0 \<union> (\<Union>n. B (n+1))). f x \<partial>M)" by simp
  also have "... = (\<integral>\<^sup>+ x \<in> B 0. f x \<partial>M) + (\<integral>\<^sup>+ x \<in> (\<Union>n. B (n+1)). f x \<partial>M)"
  proof (rule nn_integral_disjoint_pair)
    show "B 0 \<inter> (\<Union>n. B (n+1)) = {}"
      by (auto) (metis IntI Suc_neq_Zero UNIV_I empty_iff `disjoint_family B` disjoint_family_on_def)
  qed auto
  finally have "(\<integral>\<^sup>+ x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M) = (\<integral>\<^sup>+ x \<in> B 0. f x \<partial>M) + (\<integral>\<^sup>+ x \<in> (\<Union>n. B (n+1)). f x \<partial>M)"
    by simp
  moreover have "(\<integral>\<^sup>+ x \<in> (\<Union>n. B (n+1)). f x \<partial>M) = (\<Sum>n. (\<integral>\<^sup>+ x \<in> B (n+1). f x \<partial>M))"
    apply (rule nn_integral_disjoint_family) using `disjoint_family B` by (auto simp add: disjoint_family_on_def)
  ultimately have Bdec: "(\<integral>\<^sup>+ x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M) = (\<integral>\<^sup>+ x \<in> B 0. f x \<partial>M) + (\<Sum>n. \<integral>\<^sup>+ x \<in> B (n+1). f x \<partial>M)" by simp

  define D where "D = (\<lambda>n. (return_time_function A)-` {n+1})"
  then have "disjoint_family D" by (auto simp add: disjoint_family_on_def)
  have *: "\<And>n. D n = T--`(B n) \<inter> A"
    using D_def B_def return_time_rec[OF assms(1)] by simp
  then have [measurable]: "\<And>n. D n \<in> sets M" by simp
  have **: "\<And>n. B (n+1) = T--`(B n) - A" using first_entrance_rec[OF assms(1)] B_def by simp

  have pos0: "\<And>i x. f((T^^i)x) \<ge> 0" using assms(3) by simp
  have pos:"\<And> i C x. f((T^^i)x) * indicator (C) x \<ge> 0" using assms(3) by simp
  have mes0 [measurable]: "\<And> i. (\<lambda>x. f((T^^i)x)) \<in> borel_measurable M" by simp
  then have [measurable]: "\<And> i C. C \<in> sets M \<Longrightarrow> (\<lambda>x. f((T^^i)x) * indicator C x) \<in> borel_measurable M" by simp

  have "\<And>y. induced_function A f y = induced_function A f y * indicator ((return_time_function A)-`{1..}) y"
    by (rule induced_function_support)
  moreover have "(return_time_function A)-`{(1::nat)..} = (\<Union>n. D n)"
    by (auto simp add: D_def Suc_le_D)
  ultimately have "\<And>y. induced_function A f y = induced_function A f y * indicator (\<Union>n. D n) y" by simp
  then have "(\<integral>\<^sup>+y. induced_function A f y \<partial>M) = (\<integral>\<^sup>+y \<in> (\<Union>n. D n). induced_function A f y \<partial>M)" by simp
  also have "... = (\<Sum>n. (\<integral>\<^sup>+y \<in> D n. induced_function A f y \<partial>M))"
    apply (rule nn_integral_disjoint_family)
    unfolding induced_function_def by (auto simp add: pos0 sum_nonneg `disjoint_family D`)
  finally have a: "(\<integral>\<^sup>+y. induced_function A f y \<partial>M) = (\<Sum>n. (\<integral>\<^sup>+y \<in> D n. induced_function A f y \<partial>M))"
    by simp

  define d where "d = (\<lambda>i n. (\<integral>\<^sup>+y \<in> D n. f((T^^i)y) \<partial>M))"

  have "\<And>n. (\<integral>\<^sup>+y \<in> D n. induced_function A f y \<partial>M) = (\<Sum>i\<in>{..n}. d i n)"
  proof -
    fix n::nat
    have "\<And>y. induced_function A f y * indicator (D n) y = (\<Sum>i\<in>{..<n+1}. f((T^^i)y) * indicator (D n) y)"
      by (auto simp add: induced_function_def D_def indicator_def)
    then have *: "(\<integral>\<^sup>+y \<in> D n. induced_function A f y \<partial>M) = (\<Sum>i\<in>{..<n+1}. (\<integral>\<^sup>+y \<in> D n. f((T^^i)y) \<partial>M))"
      using pos nn_integral_sum[of "{..<n+1}", of "\<lambda>i y. f((T^^i)y) * indicator (D n) y"] by simp
    have "{..< n+1} = {..n}" by auto
    then have "(\<Sum>i\<in>{..<n+1}. (\<integral>\<^sup>+y \<in> D n. f((T^^i)y) \<partial>M)) = (\<Sum>i\<in>{..n}. (\<integral>\<^sup>+y \<in> D n. f((T^^i)y) \<partial>M))"
      by simp
    then show "(\<integral>\<^sup>+y \<in> D n. induced_function A f y \<partial>M) = (\<Sum>i\<in>{..n}. d i n)"
      using d_def * by simp
  qed
  then have induced_dec: "(\<integral>\<^sup>+y. induced_function A f y \<partial>M) = (\<Sum>n. (\<Sum>i\<in>{..n}. d i n))"
    using a by simp

  have "(\<Union>n\<in>{1..}. (return_time_function A)-` {n}) = UNIV - (return_time_function A)-` {0}" by auto
  then have "(\<Union>n\<in>{1..}. (return_time_function A)-` {n}) = recurrent_subset A"
    using return_time0 by auto
  moreover have "(\<Union>n. (return_time_function A)-` {n+1}) = (\<Union>n\<in>{1..}. (return_time_function A)-` {n})"
    by (auto simp add: Suc_le_D)
  ultimately have "(\<Union>n. D n) = recurrent_subset A" using D_def by simp
  moreover have "(\<integral>\<^sup>+x \<in> A. f x \<partial>M) = (\<integral>\<^sup>+x \<in> recurrent_subset A. f x \<partial>M)"
    by (rule nn_integral_null_delta, auto simp add: Diff_mono Un_absorb2 recurrent_subset_incl(1)[of A] Poincare_recurrence_thm(1)[OF assms(1)])
  moreover have "B 0 = A" using B_def first_entrance_set_def `A \<in> sets M` vimage_restr_def by simp
  ultimately have "(\<integral>\<^sup>+x \<in> B 0. f x \<partial>M) = (\<integral>\<^sup>+x \<in> (\<Union>n. D n). f x \<partial>M)" by simp
  also have "... = (\<Sum>n. (\<integral>\<^sup>+x \<in> D n. f x \<partial>M))"
    by (rule nn_integral_disjoint_family, auto simp add: `disjoint_family D`)
  finally have B0dec: "(\<integral>\<^sup>+x \<in> B 0. f x \<partial>M) = (\<Sum>n. d 0 n)" using d_def by simp

  have *: "\<And>n k. (\<integral>\<^sup>+x \<in> B n. f x \<partial>M) = (\<Sum>i<k. (\<integral>\<^sup>+x \<in> D(n+i). f((T^^(i+1))x) \<partial>M)) + (\<integral>\<^sup>+x \<in> B(n+k). f((T^^k)x) \<partial>M)"
  proof -
    fix n k::nat
    show "(\<integral>\<^sup>+x \<in> B n. f x \<partial>M) = (\<Sum>i<k. (\<integral>\<^sup>+x \<in> D(n+i). f((T^^(i+1))x) \<partial>M)) + (\<integral>\<^sup>+x \<in> B(n+k). f((T^^k)x) \<partial>M)"
    proof (induction k)
      case 0
      show ?case by simp
    next
      case (Suc k)
      have "T--`(B(n+k)) = B(n+k+1) \<union> D(n+k)" using * ** by blast

      have "(\<integral>\<^sup>+x \<in> B(n+k). f((T^^k)x) \<partial>M) = (\<integral>\<^sup>+x. (\<lambda>x. f((T^^k)x) * indicator (B (n+k)) x)(T x) \<partial>M)"
        by (rule measure_preserving_preserves_nn_integral[OF Tm], auto simp add: pos)
      also have "... = (\<integral>\<^sup>+x. f((T^^(k+1))x) * indicator (T--`(B (n+k))) x \<partial>M)"
      proof (rule nn_integral_cong_AE)
        have "\<And>x. (T^^k)(T x) = (T^^(k+1))x"
          using comp_eq_dest_lhs by (metis Suc_eq_plus1 funpow.simps(2) funpow_swap1)
        then have "\<And>x. f((T^^k)(T x)) = f((T^^(k+1))x)" by simp
        moreover have "AE x in M. f((T^^k)(T x)) * indicator (B (n+k)) (T x) = f((T^^k)(T x)) * indicator (T--`(B (n+k))) x"
          by (simp add: indicator_def vimage_restr_def `\<And>n. B n \<in> sets M`)
        ultimately show "AE x in M. f((T^^k)(T x)) * indicator (B (n+k)) (T x) = f((T^^(k+1))x) * indicator (T--`(B (n+k))) x"
          by simp
      qed
      also have "... = (\<integral>\<^sup>+x \<in> B(n+k+1) \<union> D(n+k). f((T^^(k+1))x) \<partial>M)"
        using `T--\`(B(n+k)) = B(n+k+1) \<union> D(n+k)` by simp
      also have "... = (\<integral>\<^sup>+x \<in> B(n+k+1). f((T^^(k+1))x) \<partial>M) + (\<integral>\<^sup>+x \<in> D(n+k). f((T^^(k+1))x) \<partial>M)"
      proof (rule nn_integral_disjoint_pair[OF mes0[of "k+1"]])
        show "B(n+k+1) \<inter> D(n+k) = {}" using * ** by blast
      qed (auto)
      finally have "(\<integral>\<^sup>+x \<in> B(n+k). f((T^^k)x) \<partial>M) = (\<integral>\<^sup>+x \<in> B(n+k+1). f((T^^(k+1))x) \<partial>M) + (\<integral>\<^sup>+x \<in> D(n+k). f((T^^(k+1))x) \<partial>M)"
        by simp
      then show ?case by (simp add: Suc.IH add.commute add.left_commute)
    qed
  qed

  have a: "\<And>n. (\<lambda>k. (\<integral>\<^sup>+x \<in> B(n+k). f((T^^k)x) \<partial>M)) \<longlonglongrightarrow> 0"
  proof -
    fix n::nat
    define W where "W = {x \<in> space M. f x > 0} \<inter> (T^^n)--`A"
    have "W \<subseteq> {x \<in> space M. f x > 0}" using W_def by blast
    moreover have a: "{x \<in> space M. f x > 0} \<in> sets M" using f_meas by auto
    ultimately have "emeasure M W \<le> emeasure M {x \<in> space M. f x > 0}" using emeasure_mono by metis
    then have W_fin: "emeasure M W < \<infinity>" using f_supp by auto
    have W_meas [measurable]: "W \<in> sets M" unfolding W_def by simp
    have W_incl: "W \<subseteq> (T^^n)--`A" unfolding W_def by simp

    define V where "V = (\<lambda>k. {x \<in> (T^^k)--`W. local_time A k x = 0})"
    have "\<And>k. V k = (T^^k)--`W \<inter> ((local_time A k)-`{..<1} \<inter> space M)" using V_def vimage_restr_def by blast
    then have V_meas [measurable]: "\<And>k. V k \<in> sets M" unfolding V_def by simp
    have a: "\<And>k. (\<integral>\<^sup>+x \<in> B(n+k). f((T^^k)x) \<partial>M) \<le> C * emeasure M (V k)"
    proof -
      fix k
      {
        fix x
        have "f((T^^k)x) * indicator (B(n+k)) x = f((T^^k)x) * indicator (B(n+k) \<inter> (T^^k)--`W) x"
        proof (cases)
          assume "f((T^^k)x) * indicator (B(n+k)) x = 0"
          then show ?thesis by (simp add: indicator_def)
        next
          assume "\<not>(f((T^^k)x) * indicator (B(n+k)) x = 0)"
          then have H: "f((T^^k)x) * indicator (B(n+k)) x \<noteq> 0" by simp
          then have inB: "x \<in> B(n+k)" using H using indicator_simps(2) by fastforce
          then have s: "x \<in> space M" using B_meas[of "n+k"] sets.sets_into_space by blast
          then have a: "(T^^k)x \<in> space M" by (metis measurable_space Tn_meas[of k])

          have "f((T^^k)x) > 0" using H by (simp add: le_neq_trans)
          then have *: "(T^^k)x \<in> {y \<in> space M. f y > 0}" using a by simp

          have "(T^^(n+k))x \<in> A" using inB B_def first_entrance_set_def vimage_restr_def by force
          then have "(T^^n)((T^^k)x) \<in> A" by (simp add: funpow_add)
          then have "(T^^k)x \<in> (T^^n)--`A" using a A_meas vimage_restr_def sets.sets_into_space by blast
          then have "(T^^k)x \<in> W" using * W_def by simp
          then have "x \<in> (T^^k)--`W" using s a vimage_restr_def by simp
          then have "x \<in> (B(n+k) \<inter> (T^^k)--`W)" using inB by simp
          then show ?thesis by auto
        qed
      }
      then have *: "(\<integral>\<^sup>+x \<in> B(n+k). f((T^^k)x) \<partial>M) = (\<integral>\<^sup>+x \<in> B(n+k) \<inter> (T^^k)--`W. f((T^^k)x) \<partial>M)"
        by simp
      have "B(n+k) \<subseteq> {x \<in> space M. local_time A k x = 0}"
        unfolding local_time_def B_def first_entrance_set_def
        by (auto simp add: vimage_restr_def)
      then have "B(n+k) \<inter> (T^^k)--`W \<subseteq> V k" unfolding V_def by blast
      then have "\<And>x. f((T^^k)x) * indicator (B(n+k) \<inter> (T^^k)--`W) x \<le> ennreal C * indicator (V k) x"
        using f_bound by (auto split: split_indicator)
      then have "(\<integral>\<^sup>+x \<in> B(n+k) \<inter> (T^^k)--`W. f((T^^k)x) \<partial>M) \<le> (\<integral>\<^sup>+x. ennreal C * indicator (V k) x \<partial>M)"
        by (simp add: nn_integral_mono)
      also have "... = ennreal C * emeasure M (V k)" by (simp add: `0 \<le> C` nn_integral_cmult)
      finally show "(\<integral>\<^sup>+x \<in> B(n+k). f((T^^k)x) \<partial>M) \<le> C * emeasure M (V k)" using * by simp
    qed

    have "(\<lambda>k. emeasure M (V k)) \<longlonglongrightarrow> 0" unfolding V_def
      using local_time_unbounded2[OF W_meas, OF W_fin, OF W_incl, of 1] by auto
    from ennreal_tendsto_cmult[OF _ this, of C]
    have t0: "(\<lambda>k. C * emeasure M (V k)) \<longlonglongrightarrow> 0"
      by simp
    from a show "(\<lambda>k. (\<integral>\<^sup>+x \<in> B(n+k). f((T^^k)x) \<partial>M)) \<longlonglongrightarrow> 0"
      by (intro tendsto_sandwich[OF _ _ tendsto_const t0]) auto
  qed
  have b: "\<And>n. (\<lambda>k. (\<Sum>i<k.(\<integral>\<^sup>+x \<in> D(n+i). f((T^^(i+1))x) \<partial>M))) \<longlonglongrightarrow> (\<Sum>i. d (i+1) (n+i))"
  proof -
    fix n
    define e where "e = (\<lambda>i. d (i+1) (n+i))"
    then have "(\<lambda>k. (\<Sum>i<k. e i)) \<longlonglongrightarrow> (\<Sum>i. e i)"
      by (intro summable_LIMSEQ) simp
    then show "(\<lambda>k. (\<Sum>i<k.(\<integral>\<^sup>+x \<in> D(n+i). f((T^^(i+1))x) \<partial>M))) \<longlonglongrightarrow> (\<Sum>i. d (i+1) (n+i))"
      using e_def d_def by simp
  qed

  have "\<And>n. (\<lambda>k. (\<Sum>i<k. (\<integral>\<^sup>+x \<in> D(n+i). f((T^^(i+1))x) \<partial>M)) + (\<integral>\<^sup>+x \<in> B(n+k). f((T^^k)x) \<partial>M))
                \<longlonglongrightarrow> (\<Sum>i. d (i+1) (n+i))"
    using tendsto_add[OF b a] add.right_neutral by simp
  moreover have "\<And>n. (\<lambda>k. (\<Sum>i<k. (\<integral>\<^sup>+x \<in> D(n+i). f((T^^(i+1))x) \<partial>M)) + (\<integral>\<^sup>+x \<in> B(n+k). f((T^^k)x) \<partial>M))
                \<longlonglongrightarrow> (\<integral>\<^sup>+x \<in> B n. f x \<partial>M)" using * by simp
  ultimately have "\<And>n. (\<integral>\<^sup>+x \<in> B n. f x \<partial>M) = (\<Sum>i. d (i+1) (n+i))" using LIMSEQ_unique by blast
  then have "(\<Sum>n. (\<integral>\<^sup>+x \<in> B (n+1). f x \<partial>M)) = (\<Sum>n. (\<Sum>i. d (i+1) (n+1+i)))" by simp
  then have "(\<integral>\<^sup>+ x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M) = (\<Sum>n. d 0 n) + (\<Sum>n. (\<Sum>i. d (i+1) (n+1+i)))"
    using Bdec B0dec by simp
  then show ?thesis using induced_dec kac_series_aux by simp
qed

theorem induced_function_nn_integral:
  fixes f::"'a \<Rightarrow> ennreal"
  assumes A_meas [measurable]: "A \<in> sets M"
      and f_meas [measurable]: "f \<in> borel_measurable M"
  shows "(\<integral>\<^sup>+y. induced_function A f y \<partial>M) = (\<integral>\<^sup>+ x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M)"
proof -
  obtain Y::"nat \<Rightarrow> 'a set" where Y_meas: "\<And> n. Y n \<in> sets M" and Y_fin: "\<And>n. emeasure M (Y n) \<noteq> \<infinity>"
        and Y_full: "(\<Union>n. Y n) = space M" and Y_inc: "incseq Y"
    by (meson range_subsetD sigma_finite_incseq)
  define F where "F = (\<lambda>(n::nat) x. min (f x) n * indicator (Y n) x)"
  have mes [measurable]: "\<And>n. (F n) \<in> borel_measurable M" unfolding F_def using assms(2) Y_meas by measurable
  then have mes_rel [measurable]: "\<And>n. (\<lambda>x. F n x * indicator (\<Union>n. (T^^n)--`A) x) \<in> borel_measurable M"
    by measurable
  have bound: "\<And>n x. F n x \<le> ennreal n" by (simp add: F_def indicator_def ennreal_of_nat_eq_real_of_nat)
  have "\<And>n. {x \<in> space M. F n x > 0} \<subseteq> Y n" unfolding F_def using not_le by fastforce
  then have le: "\<And>n. emeasure M {x \<in> space M. F n x > 0} \<le> emeasure M (Y n)" by (metis emeasure_mono Y_meas)
  have fin: "emeasure M {x \<in> space M. F n x > 0} < \<infinity>" for n
    using Y_fin[of n] le[of n] by (simp add: less_top)
  have *: "\<And>n. (\<integral>\<^sup>+y. induced_function A (F n) y \<partial>M) = (\<integral>\<^sup>+ x \<in> (\<Union>n. (T^^n)--`A). (F n) x \<partial>M)"
    by (rule induced_function_nn_integral_aux[OF A_meas mes bound _ fin]) simp

  have inc_Fx: "\<And>x. incseq (\<lambda>n. F n x)" unfolding F_def incseq_def
  proof (auto simp add: incseq_def)
    fix x::"'a" and m n::"nat"
    assume "m \<le> n"
    then have "min (f x) m \<le> min (f x) n" using linear by fastforce
    moreover have "(indicator (Y m) x::ennreal) \<le> (indicator (Y n) x::ennreal)" using Y_inc
      apply (auto simp add: incseq_def) using `m \<le> n` by blast
    ultimately show "min (f x) m * (indicator (Y m) x::ennreal) \<le> min (f x) n * (indicator (Y n) x::ennreal)"
      by (auto split: split_indicator)
  qed
  then have "\<And>x. incseq (\<lambda>n. F n x * indicator (\<Union>n. (T^^n)--`A) x)"
    by (auto simp add: indicator_def incseq_def)
  then have inc_rel: "incseq (\<lambda>n x. F n x * indicator (\<Union>n. (T^^n)--`A) x)" by (auto simp add: incseq_def le_fun_def)
  then have a: "(SUP n. (\<integral>\<^sup>+ x \<in> (\<Union>n. (T^^n)--`A). F n x \<partial>M))
              = (\<integral>\<^sup>+ x. (SUP n. F n x * indicator (\<Union>n. (T^^n)--`A) x) \<partial>M)"
    using nn_integral_monotone_convergence_SUP[OF inc_rel, OF mes_rel] by simp

  have SUP_Fx: "(SUP n. F n x) = f x" if "x \<in> space M" for x
  proof -
    obtain N where "x \<in> Y N" using Y_full `x \<in> space M` by auto
    have "(SUP n. F n x) = (SUP n. inf (f x) (of_nat n))"
    proof (rule SUP_eq)
      show "\<exists>j\<in>UNIV. F i x \<le> inf (f x) (of_nat j)" for i
        by (auto simp: F_def intro!: exI[of _ i] split: split_indicator)
      show "\<exists>i\<in>UNIV. inf (f x) (of_nat j) \<le> F i x" for j
        using \<open>x \<in> Y N\<close> \<open>incseq Y\<close>[THEN monoD, of N "max N j"]
        by (intro bexI[of _ "max N j"])
           (auto simp: F_def subset_eq not_le inf_min intro: min.coboundedI2 less_imp_le split: split_indicator split_max)
    qed
    then show ?thesis
      by (simp add: inf_SUP[symmetric] ennreal_SUP_of_nat_eq_top)
  qed
  then have "\<And>x. x \<in> space M \<Longrightarrow> (SUP n. F n x * indicator (\<Union>n. (T^^n)--`A) x) = f x * indicator (\<Union>n. (T^^n)--`A) x"
    by (auto simp add: indicator_def SUP_Fx)
  then have **: "(SUP n. (\<integral>\<^sup>+ x \<in> (\<Union>n. (T^^n)--`A). F n x \<partial>M)) = (\<integral>\<^sup>+ x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M)"
    by (simp add: a cong: nn_integral_cong)

  have "\<And>x. incseq (\<lambda>n. induced_function A (F n) x)"
  proof -
    fix x
    have "incseq (\<lambda>n. (\<Sum> i \<in>{..<return_time_function A x}. F n ((T^^i)x)))"
      using incseq_sumI2[of "{..<return_time_function A x}", of "\<lambda>i n. F n ((T^^i)x)"] inc_Fx by simp
    then show "incseq (\<lambda>n. induced_function A (F n) x)" by (simp add: induced_function_def)
  qed
  then have "incseq (\<lambda>n. induced_function A (F n))" by (auto simp add: incseq_def le_fun_def)
  then have b: "(SUP n. (\<integral>\<^sup>+ x. induced_function A (F n) x \<partial>M)) = (\<integral>\<^sup>+ x. (SUP n. induced_function A (F n) x) \<partial>M)"
    by (rule nn_integral_monotone_convergence_SUP[symmetric]) (measurable)

  have "\<And>x. x \<in> space M \<Longrightarrow> (SUP n. induced_function A (F n) x) = induced_function A f x"
  proof -
    fix x
    assume "x \<in> space M"
    then have "\<And>i. (T^^i)x \<in> space M" using T_spaceM_stable by simp
    then have "(SUP n. (\<Sum> i \<in>{..<return_time_function A x}. F n ((T^^i)x)))
              = (\<Sum> i \<in> {..<return_time_function A x}. f ((T^^i)x))"
      using ennreal_SUP_sum[OF inc_Fx, where ?I="{..<return_time_function A x}"] SUP_Fx by simp
    then show "(SUP n. induced_function A (F n) x) = induced_function A f x"
      by (auto simp add: induced_function_def)
  qed
  then have "(SUP n. (\<integral>\<^sup>+ x. induced_function A (F n) x \<partial>M)) = (\<integral>\<^sup>+ x. induced_function A f x \<partial>M)"
    by (simp add: b cong: nn_integral_cong)
  then show ?thesis using * ** by simp
qed

theorem kac_formula_nonergodic:
  assumes A_meas [measurable]: "A \<in> sets M"
  shows "(\<integral>\<^sup>+y. return_time_function A y \<partial>M) = emeasure M (\<Union>n. (T^^n)--`A)"
proof -
  define f where "f = (\<lambda>(x::'a). 1::ennreal)"
  have "\<And>x. induced_function A f x = return_time_function A x"
    unfolding induced_function_def f_def by (simp add:)
  then have "(\<integral>\<^sup>+y. return_time_function A y \<partial>M) = (\<integral>\<^sup>+y. induced_function A f y \<partial>M)" by auto
  also have "... = (\<integral>\<^sup>+ x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M)"
    by (rule induced_function_nn_integral) (auto simp add: f_def)
  also have "... = emeasure M (\<Union>n. (T^^n)--`A)" using f_def by auto
  finally show ?thesis by simp
qed

lemma (in fmpt) return_time_integrable:
  assumes A_meas [measurable]: "A \<in> sets M"
  shows "integrable M (return_time_function A)"
  by (rule integrableI_nonneg)
     (auto simp add: kac_formula_nonergodic[OF assms] ennreal_of_nat_eq_real_of_nat[symmetric] less_top[symmetric])

lemma induced_function_integral_aux:
  fixes f::"'a \<Rightarrow> real"
  assumes A_meas [measurable]: "A \<in> sets M"
      and f_int [measurable]: "integrable M f"
      and f_pos: "\<And>x. f x \<ge> 0"
  shows "integrable M (induced_function A f)" "(\<integral>y. induced_function A f y \<partial>M) = (\<integral>x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M)"
proof -
  show "integrable M (induced_function A f)"
  proof (rule integrableI_nonneg)
    show "AE x in M. induced_function A f x \<ge> 0" unfolding induced_function_def by (simp add: f_pos sum_nonneg)
    have "(\<integral>\<^sup>+x. ennreal (induced_function A f x) \<partial>M) = (\<integral>\<^sup>+ x. induced_function A (\<lambda>x. ennreal(f x)) x \<partial>M)"
      unfolding induced_function_def by (auto simp: f_pos)
    also have "... = (\<integral>\<^sup>+ x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M)"
      by (rule induced_function_nn_integral, auto simp add: assms)
    also have "... \<le> (\<integral>\<^sup>+ x. f x \<partial>M)"
      using nn_set_integral_set_mono[where ?A = "(\<Union>n. (T^^n)--`A)" and ?B = UNIV and ?f = "\<lambda>x. ennreal(f x)"]
      by auto
    also have "... < \<infinity>" using assms by (auto simp: less_top)
    finally show "(\<integral>\<^sup>+ x. induced_function A f x \<partial>M) < \<infinity>" by simp
  qed (simp)

  have "(\<integral>\<^sup>+ x. (f x * indicator (\<Union>n. (T^^n)--`A) x) \<partial>M) = (\<integral>\<^sup>+ x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M)"
    by (auto split: split_indicator intro!: nn_integral_cong)
  also have "... = (\<integral>\<^sup>+ x. induced_function A (\<lambda>x. ennreal(f x)) x \<partial>M)"
    by (rule induced_function_nn_integral[symmetric], auto simp add: assms)
  also have "... = (\<integral>\<^sup>+x. ennreal (induced_function A f x) \<partial>M)" unfolding induced_function_def by (auto simp: f_pos)
  finally have *: "(\<integral>\<^sup>+ x. (f x * indicator (\<Union>n. (T^^n)--`A) x) \<partial>M) = (\<integral>\<^sup>+x. ennreal (induced_function A f x) \<partial>M)"
    by simp

  have "(\<integral> x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M) = (\<integral> x. f x * indicator (\<Union>n. (T^^n)--`A) x \<partial>M)"
    by (simp add: mult.commute)
  also have "... = enn2real (\<integral>\<^sup>+ x. (f x * indicator (\<Union>n. (T^^n)--`A) x) \<partial>M)"
    by (rule integral_eq_nn_integral, auto simp add: f_pos)
  also have "... = enn2real (\<integral>\<^sup>+x. ennreal (induced_function A f x) \<partial>M)" using * by simp
  also have "... = (\<integral> x. induced_function A f x \<partial>M)"
    apply (rule integral_eq_nn_integral[symmetric])
    unfolding induced_function_def by (auto simp add: f_pos sum_nonneg)
  finally show "(\<integral> x. induced_function A f x \<partial>M) = (\<integral> x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M)"
    by simp
qed

lemma induced_function_integral_nonergodic:
  fixes f::"'a \<Rightarrow> real"
  assumes [measurable]: "A \<in> sets M" "integrable M f"
  shows "integrable M (induced_function A f)"
        "(\<integral>y. induced_function A f y \<partial>M) = (\<integral>x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M)"
proof -
  have U_meas [measurable]: "(\<Union>n. (T^^n)--`A) \<in> sets M" by measurable
  define g where "g = (\<lambda>x. max (f x) 0)"
  have g_int [measurable]: "integrable M g" unfolding g_def using assms by auto
  then have g_int2: "integrable M (induced_function A g)"
    using induced_function_integral_aux(1) g_def by auto
  define h where "h = (\<lambda>x. max (-f x) 0)"
  have h_int [measurable]: "integrable M h" unfolding h_def using assms by auto
  then have h_int2: "integrable M (induced_function A h)"
    using induced_function_integral_aux(1) h_def by auto
  have D1: "f = (\<lambda>x. g x - h x)" unfolding g_def h_def by auto
  have D2: "induced_function A f = (\<lambda>x. induced_function A g x - induced_function A h x)"
    unfolding induced_function_def using D1 by (simp add: sum_subtractf)
  then show "integrable M (induced_function A f)" using g_int2 h_int2 by auto

  have "(\<integral>x. induced_function A f x \<partial>M) = (\<integral>x. induced_function A g x - induced_function A h x \<partial>M)"
    using D2 by simp
  also have "... = (\<integral>x. induced_function A g x \<partial>M) - (\<integral>x. induced_function A h x \<partial>M)"
    using g_int2 h_int2 by auto
  also have "... = (\<integral>x \<in> (\<Union>n. (T^^n)--`A). g x \<partial>M) - (\<integral>x \<in> (\<Union>n. (T^^n)--`A). h x \<partial>M)"
    using induced_function_integral_aux(2) g_def h_def g_int h_int by auto
  also have "... = (\<integral>x \<in> (\<Union>n. (T^^n)--`A). (g x - h x) \<partial>M)"
    apply (rule set_integral_diff(2)[symmetric])
    using g_int h_int integrable_mult_indicator[OF U_meas] by blast+
  also have "... = (\<integral>x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M)"
    using D1 by simp
  finally show "(\<integral>x. induced_function A f x \<partial>M) = (\<integral>x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M)" by simp
qed

lemma induced_function_integral_restr_nonergodic:
  fixes f::"'a \<Rightarrow> real"
  assumes [measurable]: "A \<in> sets M" "integrable M f"
  shows "integrable (restrict_space M A) (induced_function A f)"
        "(\<integral>y. induced_function A f y \<partial>(restrict_space M A)) = (\<integral> x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M)"
proof -
  have [measurable]: "integrable M (induced_function A f)" by (rule induced_function_integral_nonergodic(1)[OF assms])
  then show "integrable (restrict_space M A) (induced_function A f)"
    by (metis assms(1) integrable_mult_indicator integrable_restrict_space sets.Int_space_eq2)
  have "induced_function A f y = 0" if "y \<notin> A" for y unfolding induced_function_def
    using that return_time0[of A] recurrent_subset_incl(1)[of A] return_time_function_def by auto
  then have *: "induced_function A f y = indicator A y * induced_function A f y" for y
    unfolding indicator_def by auto
  have "(\<integral>y. induced_function A f y \<partial>(restrict_space M A)) = (\<integral>y \<in> A. induced_function A f y \<partial>M)"
    by (simp add: integral_restrict_space)
  also have "... = (\<integral>y. induced_function A f y \<partial>M)" using * real_scaleR_def by presburger
  also have "... = (\<integral> x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M)"
    by (rule induced_function_integral_nonergodic(2)[OF assms])
  finally show "(\<integral>y. induced_function A f y \<partial>(restrict_space M A)) = (\<integral> x \<in> (\<Union>n. (T^^n)--`A). f x \<partial>M)"
    by simp
qed

end

text {*The Birkhoff sums of the induced function for the induced map form a subsequence of the original
Birkhoff sums for the original map, corresponding to the return times to $A$.*}

lemma (in conservative) induced_function_birkhoff_sum:
  fixes f::"'a \<Rightarrow> real"
  assumes "A \<in> sets M"
  shows "birkhoff_sum f (qmpt.birkhoff_sum (induced_map A) (return_time_function A) n x) x
          = qmpt.birkhoff_sum (induced_map A) (induced_function A f) n x"
proof -
  interpret A: conservative "restrict_space M A" "induced_map A" by (rule induced_map_is_conservative[OF assms])
  define TA where "TA = induced_map A"
  define phiA where "phiA = return_time_function A"
  define R where "R = (\<lambda>n. A.birkhoff_sum phiA n x)"
  show ?thesis
  proof (induction n)
    case 0
    show ?case using birkhoff_sum_1(1) A.birkhoff_sum_1(1) by auto
  next
    case (Suc n)
    have "(T^^(R n)) x = (TA^^n) x" unfolding TA_def R_def A.birkhoff_sum_def phiA_def by (rule induced_map_iterates[symmetric])
    have "R(n+1) = R n + phiA ((TA^^n) x)"
      unfolding R_def using A.birkhoff_sum_cocycle[where ?n= n and ?m=1 and ?f=phiA] A.birkhoff_sum_1(2) TA_def by auto
    then have "birkhoff_sum f (R (n+1)) x = birkhoff_sum f (R n) x + birkhoff_sum f (phiA ((TA^^n) x)) ((T^^(R n)) x)"
      using birkhoff_sum_cocycle[where ?n= "R n" and ?f=f] by auto
    also have "... = birkhoff_sum f (R n) x + birkhoff_sum f (phiA ((TA^^n) x)) ((TA^^n) x)"
      using `(T^^(R n)) x = (TA^^n) x` by simp
    also have "... = birkhoff_sum f (R n) x + (induced_function A f) ((TA^^n) x)"
      unfolding induced_function_def birkhoff_sum_def phiA_def by simp
    also have "... = A.birkhoff_sum (induced_function A f) n x + (induced_function A f) ((TA^^n) x)" using Suc.IH R_def phiA_def by auto
    also have "... = A.birkhoff_sum (induced_function A f) (n+1) x"
      using A.birkhoff_sum_cocycle[where ?n= n and ?m=1 and ?f="induced_function A f" and ?x=x, symmetric]
      A.birkhoff_sum_1(2)[where ?f = "induced_function A f" and ?x = "(TA^^n) x"]
      unfolding TA_def by auto
    finally show ?case unfolding R_def phiA_def by simp
  qed
qed

end
