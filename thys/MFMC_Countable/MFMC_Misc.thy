(* Author: Andreas Lochbihler, ETH Zurich *)

section \<open>Preliminaries\<close>

theory MFMC_Misc imports
  "~~/src/HOL/Probability/Probability"
  "~~/src/HOL/Library/Transitive_Closure_Table"
  "~~/src/HOL/Library/Complete_Partial_Order2"
  "~~/src/HOL/Library/Bourbaki_Witt_Fixpoint"
begin

hide_const (open) cycle
hide_const (open) path
hide_const (open) cut
hide_const (open) orthogonal

lemmas disjE [consumes 1, case_names left right, cases pred] = disjE

lemma inj_on_Pair2 [simp]: "inj_on (Pair x) A"
by(simp add: inj_on_def)

lemma inj_on_Pair1 [simp]: "inj_on (\<lambda>x. (x, y)) A"
by(simp add: inj_on_def)

lemma inj_map_prod': "\<lbrakk> inj f; inj g \<rbrakk> \<Longrightarrow> inj_on (map_prod f g) X"
by(rule subset_inj_on[OF prod.inj_map subset_UNIV])

lemma not_range_Inr: "x \<notin> range Inr \<longleftrightarrow> x \<in> range Inl"
by(cases x) auto

lemma not_range_Inl: "x \<notin> range Inl \<longleftrightarrow> x \<in> range Inr"
by(cases x) auto

lemma Chains_into_chain: "M \<in> Chains {(x, y). R x y} \<Longrightarrow> Complete_Partial_Order.chain R M"
by(simp add: Chains_def chain_def)

lemma chain_dual: "Complete_Partial_Order.chain op \<ge> = Complete_Partial_Order.chain op \<le>"
by(auto simp add: fun_eq_iff chain_def)

lemma ereal_diff_le_mono_left: "\<lbrakk> x \<le> z; 0 \<le> y \<rbrakk> \<Longrightarrow> x - y \<le> (z :: ereal)"
by(cases x y z rule: ereal3_cases) simp_all

lemma neg_0_less_iff_less_erea [simp]: "0 < - a \<longleftrightarrow> (a :: ereal) < 0"
by(cases a) simp_all

lemma not_infty_ereal: "\<bar>x\<bar> \<noteq> \<infinity> \<longleftrightarrow> (\<exists>x'. x = ereal x')"
by(cases x) simp_all

lemma neq_PInf_trans: fixes x y :: ereal shows "\<lbrakk> y \<noteq> \<infinity>; x \<le> y \<rbrakk> \<Longrightarrow> x \<noteq> \<infinity>"
by auto

lemma mult_2_ereal: "ereal 2 * x = x + x"
by(cases x) simp_all

lemma ereal_diff_le_self: "0 \<le> y \<Longrightarrow> x - y \<le> (x :: ereal)"
by(cases x y rule: ereal2_cases) simp_all

lemma ereal_le_add_self: "0 \<le> y \<Longrightarrow> x \<le> x + (y :: ereal)"
by(cases x y rule: ereal2_cases) simp_all

lemma ereal_le_add_self2: "0 \<le> y \<Longrightarrow> x \<le> y + (x :: ereal)"
by(cases x y rule: ereal2_cases) simp_all

lemma ereal_le_add_mono1: "\<lbrakk> x \<le> y; 0 \<le> (z :: ereal) \<rbrakk> \<Longrightarrow> x \<le> y + z"
using add_mono by fastforce

lemma ereal_le_add_mono2: "\<lbrakk> x \<le> z; 0 \<le> (y :: ereal) \<rbrakk> \<Longrightarrow> x \<le> y + z"
using add_mono by fastforce

lemma ereal_diff_nonpos:
  fixes a b :: ereal shows "\<lbrakk> a \<le> b; a = \<infinity> \<Longrightarrow> b \<noteq> \<infinity>; a = -\<infinity> \<Longrightarrow> b \<noteq> -\<infinity> \<rbrakk> \<Longrightarrow> a - b \<le> 0"
  by (cases rule: ereal2_cases[of a b]) auto

lemma minus_ereal_0 [simp]: "x - ereal 0 = x"
by(simp add: zero_ereal_def[symmetric])

lemma ereal_diff_eq_0_iff: fixes a b :: ereal
  shows "(\<bar>a\<bar> = \<infinity> \<Longrightarrow> \<bar>b\<bar> \<noteq> \<infinity>) \<Longrightarrow> a - b = 0 \<longleftrightarrow> a = b"
by(cases a b rule: ereal2_cases) simp_all

lemma SUP_ereal_eq_0_iff_nonneg:
  fixes f :: "_ \<Rightarrow> ereal" and A 
  assumes nonneg: "\<forall>x\<in>A. f x \<ge> 0"
  and A:"A \<noteq> {}"
  shows "(SUP x:A. f x) = 0 \<longleftrightarrow> (\<forall>x\<in>A. f x = 0)" (is "?lhs \<longleftrightarrow> ?rhs")
proof(intro iffI ballI)
  fix x
  assume "?lhs" "x \<in> A"
  from \<open>x \<in> A\<close> have "f x \<le> (SUP x:A. f x)" by(rule SUP_upper)
  with \<open>?lhs\<close> show "f x = 0" using nonneg \<open>x \<in> A\<close> by auto
qed(simp cong: SUP_cong add: A)

lemma ereal_divide_le_posI:
  fixes x y z :: ereal
  shows "x > 0 \<Longrightarrow> z \<noteq> - \<infinity> \<Longrightarrow> z \<le> x * y \<Longrightarrow> z / x \<le> y"
by (cases rule: ereal3_cases[of x y z])(auto simp: field_simps split: split_if_asm)

lemma add_diff_eq_ereal: fixes x y z :: ereal
  shows "x + (y - z) = x + y - z"
by(cases x y z rule: ereal3_cases) simp_all

lemma ereal_diff_gr0:
  fixes a b :: ereal shows "a < b \<Longrightarrow> 0 < b - a"
  by (cases rule: ereal2_cases[of a b]) auto

lemma ereal_minus_minus: fixes x y z :: ereal shows
  "(\<bar>y\<bar> = \<infinity> \<Longrightarrow> \<bar>z\<bar> \<noteq> \<infinity>) \<Longrightarrow> x - (y - z) = x + z - y"
by(cases x y z rule: ereal3_cases) simp_all

lemma diff_add_eq_ereal: fixes a b c :: ereal shows "a - b + c = a + c - b"
by(cases a b c rule: ereal3_cases) simp_all

lemma diff_diff_commute_ereal: fixes x y z :: ereal shows "x - y - z = x - z - y"
by(cases x y z rule: ereal3_cases) simp_all

lemma ereal_diff_eq_MInfty_iff: fixes x y :: ereal shows "x - y = -\<infinity> \<longleftrightarrow> x = -\<infinity> \<and> y \<noteq> -\<infinity> \<or> y = \<infinity> \<and> \<bar>x\<bar> \<noteq> \<infinity>"
by(cases x y rule: ereal2_cases) simp_all

lemma ereal_diff_add_inverse: fixes x y :: ereal shows "\<bar>x\<bar> \<noteq> \<infinity> \<Longrightarrow> x + y - x = y"
by(cases x y rule: ereal2_cases) simp_all

lemma Cauchy_real_Suc_diff:
  fixes X :: "nat \<Rightarrow> real" and x :: real
  assumes bounded: "\<And>n. \<bar>f (Suc n) - f n\<bar> \<le> (c / x ^ n)"
  and x: "1 < x"
  shows "Cauchy f"
proof(cases "c > 0")
  case c: True
  show ?thesis
  proof(rule metric_CauchyI)
    fix \<epsilon> :: real
    assume "0 < \<epsilon>"
  
    from bounded[of 0] x have c_nonneg: "0 \<le> c" by simp
    from x have "0 < ln x" by simp
    from reals_Archimedean3[OF this] obtain M :: nat
      where "ln (c * x) - ln (\<epsilon> * (x - 1)) < real M * ln x" by blast
    hence "exp (ln (c * x) - ln (\<epsilon> * (x - 1))) < exp (real M * ln x)" by(rule exp_less_mono)
    hence M: "c * (1 / x) ^ M / (1 - 1 / x) < \<epsilon>" using \<open>0 < \<epsilon>\<close> x c
      by(simp add: exp_diff exp_real_of_nat_mult field_simps)
  
    { fix n m :: nat
      assume "n \<ge> M" "m \<ge> M"
      then have "\<bar>f m - f n\<bar> \<le> c * ((1 / x) ^ M - (1 / x) ^ max m n) / (1 - 1 / x)"
      proof(induction n m rule: linorder_wlog)
        case sym thus ?case by(simp add: abs_minus_commute max.commute min.commute)
      next
        case (le m n)
        then show ?case
        proof(induction k\<equiv>"n - m" arbitrary: n m)
          case 0 thus ?case using x c_nonneg by(simp add: field_simps mult_left_mono)
        next
          case (Suc k m n)
          from \<open>Suc k = _\<close> obtain m' where m: "m = Suc m'" by(cases m) simp_all
          with \<open>Suc k = _\<close> Suc.prems have "k = m' - n" "n \<le> m'" "M \<le> n" "M \<le> m'" by simp_all
          hence "\<bar>f m' - f n\<bar> \<le> c * ((1 / x) ^ M - (1 / x) ^ (max m' n)) / (1 - 1 / x)" by(rule Suc)
          also have "\<dots> = c * ((1 / x) ^ M - (1 / x) ^ m') / (1 - 1 / x)" using \<open>n \<le> m'\<close> by(simp add: max_def)
          moreover
          from bounded have "\<bar>f m - f m'\<bar> \<le> (c / x ^ m')" by(simp add: m)
          ultimately have "\<bar>f m' - f n\<bar> + \<bar>f m - f m'\<bar> \<le> c * ((1 / x) ^ M - (1 / x) ^ m') / (1 - 1 / x) + \<dots>" by simp
          also have "\<dots> \<le> c * ((1 / x) ^ M - (1 / x) ^ m) / (1 - 1 / x)" using m x by(simp add: field_simps)
          also have "\<bar>f m - f n\<bar> \<le> \<bar>f m' - f n\<bar> + \<bar>f m - f m'\<bar>"
            using abs_triangle_ineq4[of "f m' - f n" "f m - f m'"] by simp
          ultimately show ?case using \<open>n \<le> m\<close> by(simp add: max_def)
        qed
      qed
      also have "\<dots> < c * (1 / x) ^ M / (1 - 1 / x)" using x c by(auto simp add: field_simps)
      also have "\<dots> < \<epsilon>" using M .
      finally have "\<bar>f m - f n\<bar> < \<epsilon>" . }
    thus "\<exists>M. \<forall>m\<ge>M. \<forall>n\<ge>M. dist (f m) (f n) < \<epsilon>" unfolding dist_real_def by blast
  qed
next
  case False
  with bounded[of 0] have [simp]: "c = 0" by simp
  have eq: "f m = f 0" for m
  proof(induction m)
    case (Suc m) from bounded[of m] Suc.IH show ?case by simp
  qed simp
  show ?thesis by(rule metric_CauchyI)(subst (1 2) eq; simp)
qed

lemma complete_lattice_ccpo_dual:
  "class.ccpo Inf op \<ge> (op > :: _ :: complete_lattice \<Rightarrow> _)"
by(unfold_locales)(auto intro: Inf_lower Inf_greatest)

lemma card_eq_1_iff: "card A = Suc 0 \<longleftrightarrow> (\<exists>x. A = {x})"
using card_eq_SucD by auto

lemma nth_rotate1: "n < length xs \<Longrightarrow> rotate1 xs ! n = xs ! (Suc n mod length xs)"
apply(cases xs; clarsimp simp add: nth_append not_less)
apply(subgoal_tac "n = length list"; simp)
done

lemma set_zip_rightI: "\<lbrakk> x \<in> set ys; length xs \<ge> length ys \<rbrakk> \<Longrightarrow> \<exists>z. (z, x) \<in> set (zip xs ys)"
by(fastforce simp add: in_set_zip in_set_conv_nth simp del: length_greater_0_conv intro!: nth_zip conjI[rotated])

lemma map_eq_append_conv:
  "map f xs = ys @ zs \<longleftrightarrow> (\<exists>ys' zs'. xs = ys' @ zs' \<and> ys = map f ys' \<and> zs = map f zs')"
by(auto 4 4 intro: exI[where x="take (length ys) xs"] exI[where x="drop (length ys) xs"] simp add: append_eq_conv_conj take_map drop_map dest: sym)

lemma rotate1_append:
  "rotate1 (xs @ ys) = (if xs = [] then rotate1 ys else tl xs @ ys @ [hd xs])"
by(clarsimp simp add: neq_Nil_conv)

lemma in_set_tlD: "x \<in> set (tl xs) \<Longrightarrow> x \<in> set xs"
by(cases xs) simp_all

lemma tendsto_diff_ereal:
  fixes x y :: ereal
  assumes x: "\<bar>x\<bar> \<noteq> \<infinity>" and y: "\<bar>y\<bar> \<noteq> \<infinity>"
  assumes f: "(f \<longlongrightarrow> x) F" and g: "(g \<longlongrightarrow> y) F"
  shows "((\<lambda>x. f x - g x) \<longlongrightarrow> x - y) F"
proof -
  from x obtain r where x': "x = ereal r" by (cases x) auto
  with f have "((\<lambda>i. real_of_ereal (f i)) \<longlongrightarrow> r) F" by simp
  moreover
  from y obtain p where y': "y = ereal p" by (cases y) auto
  with g have "((\<lambda>i. real_of_ereal (g i)) \<longlongrightarrow> p) F" by simp
  ultimately have "((\<lambda>i. real_of_ereal (f i) - real_of_ereal (g i)) \<longlongrightarrow> r - p) F"
    by (rule tendsto_diff)
  moreover
  from eventually_finite[OF x f] eventually_finite[OF y g]
  have "eventually (\<lambda>x. f x - g x = ereal (real_of_ereal (f x) - real_of_ereal (g x))) F"
    by eventually_elim auto
  ultimately show ?thesis
    by (simp add: x' y' cong: filterlim_cong)
qed

lemma countable_converseI:
  assumes "countable A"
  shows "countable (converse A)"
proof -
  have "converse A = prod.swap ` A" by auto
  then show ?thesis using assms by simp
qed

lemma countable_converse [simp]: "countable (converse A) \<longleftrightarrow> countable A"
using countable_converseI[of A] countable_converseI[of "converse A"] by auto

lemma nn_integral_count_space_reindex:
  "inj_on f A \<Longrightarrow>(\<integral>\<^sup>+ y. g y \<partial>count_space (f ` A)) = (\<integral>\<^sup>+ x. g (f x) \<partial>count_space A)"
by(simp add: embed_measure_count_space'[symmetric] nn_integral_embed_measure' measurable_embed_measure1)

syntax
  "_nn_sum" :: "pttrn \<Rightarrow> 'a set \<Rightarrow> 'b \<Rightarrow> 'b::comm_monoid_add"  ("(2\<Sum>\<^sup>+ _\<in>_./ _)" [0, 51, 10] 10)
  "_nn_sum_UNIV" :: "pttrn \<Rightarrow> 'b \<Rightarrow> 'b::comm_monoid_add" ("(2\<Sum>\<^sup>+ _./ _)" [0, 10] 10)
translations
  "\<Sum>\<^sup>+ i\<in>A. b" \<rightleftharpoons> "CONST nn_integral (CONST count_space A) (\<lambda>i. b)"
  "\<Sum>\<^sup>+ i. b" \<rightleftharpoons> "\<Sum>\<^sup>+ i\<in>CONST UNIV. b"

inductive_simps rtrancl_path_simps:
  "rtrancl_path R x [] y"
  "rtrancl_path R x (a # bs) y"

definition restrict_rel :: "'a set \<Rightarrow> ('a \<times> 'a) set \<Rightarrow> ('a \<times> 'a) set"
where "restrict_rel A R = {(x, y)\<in>R. x \<in> A \<and> y \<in> A}"

lemma in_restrict_rel_iff: "(x, y) \<in> restrict_rel A R \<longleftrightarrow> (x, y) \<in> R \<and> x \<in> A \<and> y \<in> A"
by(simp add: restrict_rel_def)

lemma restrict_relE: "\<lbrakk> (x, y) \<in> restrict_rel A R; \<lbrakk> (x, y) \<in> R; x \<in> A; y \<in> A \<rbrakk> \<Longrightarrow> thesis \<rbrakk> \<Longrightarrow> thesis"
by(simp add: restrict_rel_def)

lemma restrict_relI [intro!]: "\<lbrakk> (x, y) \<in> R; x \<in> A; y \<in> A \<rbrakk> \<Longrightarrow> (x, y) \<in> restrict_rel A R"
by(simp add: restrict_rel_def)

lemma Field_restrict_rel_subset: "Field (restrict_rel A R) \<subseteq> A \<inter> Field R"
by(auto simp add: Field_def in_restrict_rel_iff)

lemma Field_restrict_rel [simp]: "Refl R \<Longrightarrow> Field (restrict_rel A R) = A \<inter> Field R"
using Field_restrict_rel_subset[of A R]
by auto (auto simp add: Field_def dest: refl_onD)

lemma Partial_order_restrict_rel: 
  assumes "Partial_order R"
  shows "Partial_order (restrict_rel A R)"
proof -
  from assms have "Refl R" by(simp add: order_on_defs)
  from Field_restrict_rel[OF this, of A] assms show ?thesis
    by(simp add: order_on_defs trans_def antisym_def)
      (auto intro: FieldI1 FieldI2 intro!: refl_onI simp add: in_restrict_rel_iff elim: refl_onD)
qed

lemma Chains_restrict_relD: "M \<in> Chains (restrict_rel A leq) \<Longrightarrow> M \<in> Chains leq"
by(auto simp add: Chains_def in_restrict_rel_iff)

lemma bourbaki_witt_fixpoint_restrict_rel:
  assumes leq: "Partial_order leq"
  and chain_Field: "\<And>M. \<lbrakk> M \<in> Chains (restrict_rel A leq); M \<noteq> {} \<rbrakk> \<Longrightarrow> lub M \<in> A" 
  and lub_least: "\<And>M z. \<lbrakk> M \<in> Chains leq; M \<noteq> {}; \<And>x. x \<in> M \<Longrightarrow> (x, z) \<in> leq \<rbrakk> \<Longrightarrow> (lub M, z) \<in> leq"
  and lub_upper: "\<And>M z. \<lbrakk> M \<in> Chains leq; z \<in> M \<rbrakk> \<Longrightarrow> (z, lub M) \<in> leq"
  and increasing: "\<And>x. \<lbrakk> x \<in> A; x \<in> Field leq \<rbrakk> \<Longrightarrow> (x, f x) \<in> leq \<and> f x \<in> A"
  shows "bourbaki_witt_fixpoint lub (restrict_rel A leq) f"
proof
  show "Partial_order (restrict_rel A leq)" using leq by(rule Partial_order_restrict_rel)
next
  from leq have Refl: "Refl leq" by(simp add: order_on_defs)

  { fix M z
    assume M: "M \<in> Chains (restrict_rel A leq)"
    presume z: "z \<in> M"
    hence "M \<noteq> {}" by auto
    with M have lubA: "lub M \<in> A" by(rule chain_Field)
    from M have M': "M \<in> Chains leq" by(rule Chains_restrict_relD)
    then have *: "(z, lub M) \<in> leq" using z by(rule lub_upper)
    hence "lub M \<in> Field leq" by(rule FieldI2)
    with lubA show "lub M \<in> Field (restrict_rel A leq)" by(simp add: Field_restrict_rel[OF Refl])
    from Chains_FieldD[OF M z] have "z \<in> A" by(simp add: Field_restrict_rel[OF Refl])
    with * lubA show "(z, lub M ) \<in> restrict_rel A leq" by auto
  
    fix z
    assume upper: "\<And>x. x \<in> M \<Longrightarrow> (x, z) \<in> restrict_rel A leq"
    from upper[OF z] have "z \<in> Field (restrict_rel A leq)" by(auto simp add: Field_def)
    with Field_restrict_rel_subset[of A leq] have "z \<in> A" by blast
    moreover from lub_least[OF M' \<open>M \<noteq> {}\<close>] upper have "(lub M, z) \<in> leq" 
      by(auto simp add: in_restrict_rel_iff)
    ultimately show "(lub M, z) \<in> restrict_rel A leq" using lubA by(simp add: in_restrict_rel_iff) }
  { fix x
    assume "x \<in> Field (restrict_rel A leq)"
    hence "x \<in> A" "x \<in> Field leq" by(simp_all add: Field_restrict_rel[OF Refl])
    with increasing[OF this] show "(x, f x) \<in> restrict_rel A leq" by auto }
  show "(SOME x. x \<in> M) \<in> M" "(SOME x. x \<in> M) \<in> M" if "M \<noteq> {}" for M :: "'a set"
    using that by(auto intro: someI)
qed

lemma Field_le [simp]: "Field {(x :: _ :: preorder, y). x \<le> y} = UNIV"
by(auto intro: FieldI1)

lemma Field_ge [simp]: "Field {(x :: _ :: preorder, y). y \<le> x} = UNIV"
by(auto intro: FieldI1)

lemma refl_le [simp]: "refl {(x :: _ :: preorder, y). x \<le> y}"
by(auto intro!: refl_onI simp add: Field_def)

lemma refl_ge [simp]: "refl {(x :: _ :: preorder, y). y \<le> x}"
by(auto intro!: refl_onI simp add: Field_def)

lemma partial_order_le [simp]: "partial_order_on UNIV {(x :: _ :: order, x'). x \<le> x'}"
by(auto simp add: order_on_defs trans_def antisym_def)

lemma partial_order_ge [simp]: "partial_order_on UNIV {(x :: _ :: order, x'). x' \<le> x}"
by(auto simp add: order_on_defs trans_def antisym_def)

lemma incseq_chain_range: "incseq f \<Longrightarrow> Complete_Partial_Order.chain op \<le> (range f)"
apply(rule chainI; clarsimp)
subgoal for x y using linear[of x y] by(auto dest: incseqD)
done

end
