section \<open>Order and Equivalence on Lenses\<close>

theory Lens_Order
imports Lens_Algebra
begin

subsection \<open>Sub-lens Relation\<close>
  
text \<open>A lens $X$ is a sub-lens of $Y$ if there is a well-behaved lens $Z$ such that $X = Z \lcomp Y$,
  or in other words if $X$ can be expressed purely in terms of $Y$.\<close>

definition sublens :: "('a \<Longrightarrow> 'c) \<Rightarrow> ('b \<Longrightarrow> 'c) \<Rightarrow> bool" (infix "\<subseteq>\<^sub>L" 55) where
[lens_defs]: "sublens X Y = (\<exists> Z :: ('a, 'b) lens. vwb_lens Z \<and> X = Z ;\<^sub>L Y)"

text \<open>Various lens classes are downward closed under the sublens relation.\<close>

lemma sublens_pres_mwb:
  "\<lbrakk> mwb_lens Y; X \<subseteq>\<^sub>L Y \<rbrakk> \<Longrightarrow> mwb_lens X"
  by (unfold_locales, auto simp add: sublens_def lens_comp_def)

lemma sublens_pres_wb:
  "\<lbrakk> wb_lens Y; X \<subseteq>\<^sub>L Y \<rbrakk> \<Longrightarrow> wb_lens X"
  by (unfold_locales, auto simp add: sublens_def lens_comp_def)

lemma sublens_pres_vwb:
  "\<lbrakk> vwb_lens Y; X \<subseteq>\<^sub>L Y \<rbrakk> \<Longrightarrow> vwb_lens X"
  by (unfold_locales, auto simp add: sublens_def lens_comp_def)

text \<open>Sublens is a preorder as the following two theorems show.\<close>
    
lemma sublens_refl:
  "X \<subseteq>\<^sub>L X"
  using id_vwb_lens sublens_def by fastforce

lemma sublens_trans [trans]:
  "\<lbrakk> X \<subseteq>\<^sub>L Y; Y \<subseteq>\<^sub>L Z \<rbrakk> \<Longrightarrow> X \<subseteq>\<^sub>L Z"
  apply (auto simp add: sublens_def lens_comp_assoc)
  apply (rename_tac Z\<^sub>1 Z\<^sub>2)
  apply (rule_tac x="Z\<^sub>1 ;\<^sub>L Z\<^sub>2" in exI)
  apply (simp add: lens_comp_assoc)
  using comp_vwb_lens apply blast
done

text \<open>Sublens has a least element -- @{text "0\<^sub>L"} -- and a greatest element -- @{text "1\<^sub>L"}. 
  Intuitively, this shows that sublens orders how large a portion of the source type a particular
  lens views, with @{text "0\<^sub>L"} observing the least, and @{text "1\<^sub>L"} observing the most.\<close>
  
lemma sublens_least: "wb_lens X \<Longrightarrow> 0\<^sub>L \<subseteq>\<^sub>L X"
  using sublens_def unit_vwb_lens by fastforce

lemma sublens_greatest: "vwb_lens X \<Longrightarrow> X \<subseteq>\<^sub>L 1\<^sub>L"
  by (simp add: sublens_def)

text \<open>If $Y$ is a sublens of $X$ then any put using $X$ will necessarily erase any put using $Y$.
  Similarly, any two source types are observationally equivalent by $Y$ when performed
  following a put using $X$.\<close>
    
lemma sublens_put_put:
  "\<lbrakk> mwb_lens X; Y \<subseteq>\<^sub>L X \<rbrakk> \<Longrightarrow> put\<^bsub>X\<^esub> (put\<^bsub>Y\<^esub> \<sigma> v) u = put\<^bsub>X\<^esub> \<sigma> u"
  by (auto simp add: sublens_def lens_comp_def)

lemma sublens_obs_get:
  "\<lbrakk> mwb_lens X; Y \<subseteq>\<^sub>L X \<rbrakk> \<Longrightarrow>  get\<^bsub>Y\<^esub> (put\<^bsub>X\<^esub> \<sigma> v) = get\<^bsub>Y\<^esub> (put\<^bsub>X\<^esub> \<rho> v)"
  by (auto simp add: sublens_def lens_comp_def)

text \<open>Sublens preserves independence; in other words if $Y$ is independent of $Z$, then also
  any $X$ smaller than $Y$ is independent of $Z$.\<close>
    
lemma sublens_pres_indep:
  "\<lbrakk> X \<subseteq>\<^sub>L Y; Y \<bowtie> Z \<rbrakk> \<Longrightarrow> X \<bowtie> Z"
  apply (auto intro!:lens_indepI simp add: sublens_def lens_comp_def lens_indep_comm)
  apply (simp add: lens_indep_sym)
done

text \<open>Well-behavedness of lens quotient has sublens as a proviso. This is because we can only
  remove $X$ from $Y$ if $X$ is smaller than $Y$. \<close>
  
lemma lens_quotient_mwb:
  "\<lbrakk> mwb_lens Y; X \<subseteq>\<^sub>L Y \<rbrakk> \<Longrightarrow> mwb_lens (X /\<^sub>L Y)"
  by (unfold_locales, auto simp add: lens_quotient_def lens_create_def sublens_def lens_comp_def comp_def)
    
subsection \<open>Lens Equivalence\<close>
    
text \<open>Using our preorder, we can also derive an equivalence on lenses as follows. It should be
  noted that this equality, like sublens, is heterogeneously typed -- it can compare lenses whose
  view types are different, so long as the source types are the same. We show that it is reflexive, 
  symmetric, and transitive. \<close>
    
definition lens_equiv :: "('a \<Longrightarrow> 'c) \<Rightarrow> ('b \<Longrightarrow> 'c) \<Rightarrow> bool" (infix "\<approx>\<^sub>L" 51) where
[lens_defs]: "lens_equiv X Y = (X \<subseteq>\<^sub>L Y \<and> Y \<subseteq>\<^sub>L X)"

lemma lens_equivI [intro]:
  "\<lbrakk> X \<subseteq>\<^sub>L Y; Y \<subseteq>\<^sub>L X \<rbrakk> \<Longrightarrow> X \<approx>\<^sub>L Y"
  by (simp add: lens_equiv_def)

lemma lens_equiv_refl:
  "X \<approx>\<^sub>L X"
  by (simp add: lens_equiv_def sublens_refl)

lemma lens_equiv_sym:
  "X \<approx>\<^sub>L Y \<Longrightarrow> Y \<approx>\<^sub>L X"
  by (simp add: lens_equiv_def)

lemma lens_equiv_trans [trans]:
  "\<lbrakk> X \<approx>\<^sub>L Y; Y \<approx>\<^sub>L Z \<rbrakk> \<Longrightarrow> X \<approx>\<^sub>L Z"
  by (auto intro: sublens_trans simp add: lens_equiv_def)

subsection \<open>Further Algebraic Laws\<close>

text \<open>This law explains the behaviour of lens quotient.\<close>

lemma lens_quotient_comp:
  "\<lbrakk> weak_lens Y; X \<subseteq>\<^sub>L Y \<rbrakk> \<Longrightarrow> (X /\<^sub>L Y) ;\<^sub>L Y = X"
  by (auto simp add: lens_quotient_def lens_comp_def comp_def sublens_def)

text \<open>Plus distributes through quotient.\<close>
    
lemma lens_quotient_plus:
  "\<lbrakk> mwb_lens Z; X \<subseteq>\<^sub>L Z; Y \<subseteq>\<^sub>L Z \<rbrakk> \<Longrightarrow> (X +\<^sub>L Y) /\<^sub>L Z = (X /\<^sub>L Z) +\<^sub>L (Y /\<^sub>L Z)"
  apply (auto simp add: lens_quotient_def lens_plus_def sublens_def lens_comp_def comp_def)
  apply (rule ext)
  apply (rule ext)
  apply (simp add: prod.case_eq_if)
done

text \<open>There follows a number of laws relating sublens and summation. Firstly, sublens is preserved
  by summation. \<close>
  
lemma plus_pred_sublens: "\<lbrakk> mwb_lens Z; X \<subseteq>\<^sub>L Z; Y \<subseteq>\<^sub>L Z; X \<bowtie> Y \<rbrakk> \<Longrightarrow> (X +\<^sub>L Y) \<subseteq>\<^sub>L Z"
  apply (auto simp add: sublens_def)
  apply (rename_tac Z\<^sub>1 Z\<^sub>2)
  apply (rule_tac x="Z\<^sub>1 +\<^sub>L Z\<^sub>2" in exI)
  apply (auto intro!: plus_wb_lens)
   apply (simp add: lens_comp_indep_cong_left plus_vwb_lens)
  apply (simp add: plus_lens_distr)
done

text \<open>Intuitively, lens plus is associative. However we cannot prove this using HOL equality due
  to monomorphic typing of this operator. But since sublens and lens equivalence are both heterogeneous
  we can now prove this in the following three lemmas.\<close>
  
lemma lens_plus_sub_assoc_1:
  "X +\<^sub>L Y +\<^sub>L Z \<subseteq>\<^sub>L (X +\<^sub>L Y) +\<^sub>L Z"
  apply (simp add: sublens_def)
  apply (rule_tac x="(fst\<^sub>L ;\<^sub>L fst\<^sub>L) +\<^sub>L (snd\<^sub>L ;\<^sub>L fst\<^sub>L) +\<^sub>L snd\<^sub>L" in exI)
  apply (auto)
   apply (rule plus_vwb_lens)
     apply (simp add: comp_vwb_lens fst_vwb_lens)
    apply (rule plus_vwb_lens)
      apply (simp add: comp_vwb_lens fst_vwb_lens snd_vwb_lens)
     apply (simp add: snd_vwb_lens)
    apply (simp add: lens_indep_left_ext)
   apply (rule lens_indep_sym)
   apply (rule plus_pres_lens_indep)
    using fst_snd_lens_indep fst_vwb_lens lens_indep_left_comp lens_indep_sym vwb_lens_mwb apply blast
   using fst_snd_lens_indep lens_indep_left_ext lens_indep_sym apply blast
  apply (auto simp add: lens_plus_def lens_comp_def fst_lens_def snd_lens_def prod.case_eq_if split_beta')[1]
done

lemma lens_plus_sub_assoc_2:
  "(X +\<^sub>L Y) +\<^sub>L Z \<subseteq>\<^sub>L X +\<^sub>L Y +\<^sub>L Z"
  apply (simp add: sublens_def)
  apply (rule_tac x="(fst\<^sub>L +\<^sub>L (fst\<^sub>L ;\<^sub>L snd\<^sub>L)) +\<^sub>L (snd\<^sub>L ;\<^sub>L snd\<^sub>L)" in exI)
  apply (auto)
   apply (rule plus_vwb_lens)
     apply (rule plus_vwb_lens)
       apply (simp add: fst_vwb_lens)
      apply (simp add: comp_vwb_lens fst_vwb_lens snd_vwb_lens)
     apply (rule lens_indep_sym)
     apply (rule lens_indep_left_ext)
     using fst_snd_lens_indep lens_indep_sym apply blast
    apply (auto intro: comp_vwb_lens simp add: snd_vwb_lens)
   apply (rule plus_pres_lens_indep)
    apply (simp add: lens_indep_left_ext lens_indep_sym)
   apply (simp add: snd_vwb_lens)
  apply (auto simp add: lens_plus_def lens_comp_def fst_lens_def snd_lens_def prod.case_eq_if split_beta')[1]
done

lemma lens_plus_assoc:
  "(X +\<^sub>L Y) +\<^sub>L Z \<approx>\<^sub>L X +\<^sub>L Y +\<^sub>L Z"
  by (simp add: lens_equivI lens_plus_sub_assoc_1 lens_plus_sub_assoc_2)

text \<open>We can similarly show that it is commutative.\<close>
    
lemma lens_plus_sub_comm: "X \<bowtie> Y \<Longrightarrow> X +\<^sub>L Y \<subseteq>\<^sub>L Y +\<^sub>L X"
  apply (simp add: sublens_def)
  apply (rule_tac x="snd\<^sub>L +\<^sub>L fst\<^sub>L" in exI)
  apply (auto)
   apply (simp add: fst_vwb_lens lens_indep_sym plus_vwb_lens snd_vwb_lens)
  apply (simp add: lens_indep_sym lens_plus_swap)
done

lemma lens_plus_comm: "X \<bowtie> Y \<Longrightarrow> X +\<^sub>L Y \<approx>\<^sub>L Y +\<^sub>L X"
  by (simp add: lens_equivI lens_indep_sym lens_plus_sub_comm)

text \<open>Any composite lens is larger than an element of the lens, as demonstrated by the following
  four laws.\<close>
    
lemma lens_plus_ub: "wb_lens Y \<Longrightarrow> X \<subseteq>\<^sub>L X +\<^sub>L Y"
  by (metis fst_lens_plus fst_vwb_lens sublens_def)

lemma lens_plus_right_sublens:
  "\<lbrakk> vwb_lens Y; Y \<bowtie> Z; X \<subseteq>\<^sub>L Z \<rbrakk> \<Longrightarrow> X \<subseteq>\<^sub>L Y +\<^sub>L Z"
  apply (auto simp add: sublens_def)
  apply (rename_tac Z')
  apply (rule_tac x="Z' ;\<^sub>L snd\<^sub>L" in exI)
  apply (auto)
   using comp_vwb_lens snd_vwb_lens apply blast
  apply (simp add: lens_comp_assoc snd_lens_plus)
done
    
lemma lens_plus_mono_left:
  "\<lbrakk> Y \<bowtie> Z; X \<subseteq>\<^sub>L Y \<rbrakk> \<Longrightarrow> X +\<^sub>L Z \<subseteq>\<^sub>L Y +\<^sub>L Z"
  apply (auto simp add: sublens_def)
  apply (rename_tac Z')
  apply (rule_tac x="Z' \<times>\<^sub>L 1\<^sub>L" in exI)
  apply (subst prod_lens_comp_plus)
   apply (simp_all)
  using id_vwb_lens prod_vwb_lens apply blast
done
    
lemma lens_plus_mono_right:
  "\<lbrakk> X \<bowtie> Z; Y \<subseteq>\<^sub>L Z \<rbrakk> \<Longrightarrow> X +\<^sub>L Y \<subseteq>\<^sub>L X +\<^sub>L Z"
  by (metis prod_lens_comp_plus prod_vwb_lens sublens_def sublens_refl)
    
text \<open>If we compose a lens $X$ with lens $Y$ then naturally the resulting lens must be smaller
  than $Y$, as $X$ views a part of $Y$. \<close>
  
lemma lens_comp_lb [simp]: "vwb_lens X \<Longrightarrow> X ;\<^sub>L Y \<subseteq>\<^sub>L Y"
  by (auto simp add: sublens_def)

text \<open>We can now also show that @{text "0\<^sub>L"} is the unit of lens plus\<close>
    
lemma lens_unit_plus_sublens_1: "X \<subseteq>\<^sub>L 0\<^sub>L +\<^sub>L X"
  by (metis lens_comp_lb snd_lens_plus snd_vwb_lens zero_lens_indep unit_wb_lens)

lemma lens_unit_prod_sublens_2: "0\<^sub>L +\<^sub>L X \<subseteq>\<^sub>L X"
  apply (auto simp add: sublens_def)
  apply (rule_tac x="0\<^sub>L +\<^sub>L 1\<^sub>L" in exI)
  apply (auto)
   apply (rule plus_vwb_lens)
     apply (simp_all)
  apply (auto simp add: lens_plus_def zero_lens_def lens_comp_def id_lens_def prod.case_eq_if comp_def)
  apply (rule ext)
  apply (rule ext)
  apply (auto)
done

lemma lens_plus_left_unit: "0\<^sub>L +\<^sub>L X \<approx>\<^sub>L X"
  by (simp add: lens_equivI lens_unit_plus_sublens_1 lens_unit_prod_sublens_2)

lemma lens_plus_right_unit: "X +\<^sub>L 0\<^sub>L \<approx>\<^sub>L X"
  using lens_equiv_trans lens_indep_sym lens_plus_comm lens_plus_left_unit zero_lens_indep by blast

text \<open>We can also show that both sublens and equivalence are congruences with respect to lens plus
  and lens product.\<close>
    
lemma lens_plus_subcong: "\<lbrakk> Y\<^sub>1 \<bowtie> Y\<^sub>2; X\<^sub>1 \<subseteq>\<^sub>L Y\<^sub>1; X\<^sub>2 \<subseteq>\<^sub>L Y\<^sub>2 \<rbrakk> \<Longrightarrow> X\<^sub>1 +\<^sub>L X\<^sub>2 \<subseteq>\<^sub>L Y\<^sub>1 +\<^sub>L Y\<^sub>2"
  by (metis prod_lens_comp_plus prod_vwb_lens sublens_def)

lemma lens_plus_eq_left: "\<lbrakk> X \<bowtie> Z; X \<approx>\<^sub>L Y \<rbrakk> \<Longrightarrow> X +\<^sub>L Z \<approx>\<^sub>L Y +\<^sub>L Z"
  by (meson lens_equiv_def lens_plus_mono_left sublens_pres_indep)

lemma lens_plus_eq_right: "\<lbrakk> X \<bowtie> Y; Y \<approx>\<^sub>L Z \<rbrakk> \<Longrightarrow> X +\<^sub>L Y \<approx>\<^sub>L X +\<^sub>L Z"
  by (meson lens_equiv_def lens_indep_sym lens_plus_mono_right sublens_pres_indep)

lemma lens_plus_cong:
  assumes "X\<^sub>1 \<bowtie> X\<^sub>2" "X\<^sub>1 \<approx>\<^sub>L Y\<^sub>1" "X\<^sub>2 \<approx>\<^sub>L Y\<^sub>2"
  shows "X\<^sub>1 +\<^sub>L X\<^sub>2 \<approx>\<^sub>L Y\<^sub>1 +\<^sub>L Y\<^sub>2"
proof -
  have "X\<^sub>1 +\<^sub>L X\<^sub>2 \<approx>\<^sub>L Y\<^sub>1 +\<^sub>L X\<^sub>2"
    by (simp add: assms(1) assms(2) lens_plus_eq_left)
  moreover have "... \<approx>\<^sub>L Y\<^sub>1 +\<^sub>L Y\<^sub>2"
    using assms(1) assms(2) assms(3) lens_equiv_def lens_plus_eq_right sublens_pres_indep by blast
  ultimately show ?thesis
    using lens_equiv_trans by blast
qed

lemma prod_lens_sublens_cong:
  "\<lbrakk> X\<^sub>1 \<subseteq>\<^sub>L X\<^sub>2; Y\<^sub>1 \<subseteq>\<^sub>L Y\<^sub>2 \<rbrakk> \<Longrightarrow> (X\<^sub>1 \<times>\<^sub>L Y\<^sub>1) \<subseteq>\<^sub>L (X\<^sub>2 \<times>\<^sub>L Y\<^sub>2)"
  apply (auto simp add: sublens_def)
  apply (rename_tac Z\<^sub>1 Z\<^sub>2)
  apply (rule_tac x="Z\<^sub>1 \<times>\<^sub>L Z\<^sub>2" in exI)
  apply (auto)
   using prod_vwb_lens apply blast
  apply (auto simp add: lens_prod_def lens_comp_def prod.case_eq_if)
  apply (rule ext, rule ext)
  apply (auto simp add: lens_prod_def lens_comp_def prod.case_eq_if)
done

lemma prod_lens_equiv_cong:
  "\<lbrakk> X\<^sub>1 \<approx>\<^sub>L X\<^sub>2; Y\<^sub>1 \<approx>\<^sub>L Y\<^sub>2 \<rbrakk> \<Longrightarrow> (X\<^sub>1 \<times>\<^sub>L Y\<^sub>1) \<approx>\<^sub>L (X\<^sub>2 \<times>\<^sub>L Y\<^sub>2)"
  by (simp add: lens_equiv_def prod_lens_sublens_cong)

text \<open>We also have the following "exchange" law that allows us to switch over a lens product and plus.\<close> 
    
lemma lens_plus_prod_exchange:
  "(X\<^sub>1 +\<^sub>L X\<^sub>2) \<times>\<^sub>L (Y\<^sub>1 +\<^sub>L Y\<^sub>2) \<approx>\<^sub>L (X\<^sub>1 \<times>\<^sub>L Y\<^sub>1) +\<^sub>L (X\<^sub>2 \<times>\<^sub>L Y\<^sub>2)"
proof (rule lens_equivI)
  show "(X\<^sub>1 +\<^sub>L X\<^sub>2) \<times>\<^sub>L (Y\<^sub>1 +\<^sub>L Y\<^sub>2) \<subseteq>\<^sub>L (X\<^sub>1 \<times>\<^sub>L Y\<^sub>1) +\<^sub>L (X\<^sub>2 \<times>\<^sub>L Y\<^sub>2)"
    apply (simp add: sublens_def)
    apply (rule_tac x="((fst\<^sub>L ;\<^sub>L fst\<^sub>L) +\<^sub>L (fst\<^sub>L ;\<^sub>L snd\<^sub>L)) +\<^sub>L ((snd\<^sub>L ;\<^sub>L fst\<^sub>L) +\<^sub>L (snd\<^sub>L ;\<^sub>L snd\<^sub>L))" in exI)
    apply (auto)
     apply (auto intro!: plus_vwb_lens comp_vwb_lens fst_vwb_lens snd_vwb_lens lens_indep_right_comp)
       apply (auto intro!: lens_indepI simp add: lens_comp_def lens_plus_def fst_lens_def snd_lens_def)
    apply (auto simp add: lens_prod_def lens_plus_def lens_comp_def fst_lens_def snd_lens_def prod.case_eq_if comp_def)[1]
    apply (rule ext, rule ext, auto simp add: prod.case_eq_if)
  done
  show "(X\<^sub>1 \<times>\<^sub>L Y\<^sub>1) +\<^sub>L (X\<^sub>2 \<times>\<^sub>L Y\<^sub>2) \<subseteq>\<^sub>L (X\<^sub>1 +\<^sub>L X\<^sub>2) \<times>\<^sub>L (Y\<^sub>1 +\<^sub>L Y\<^sub>2)"
    apply (simp add: sublens_def)
    apply (rule_tac x="((fst\<^sub>L ;\<^sub>L fst\<^sub>L) +\<^sub>L (fst\<^sub>L ;\<^sub>L snd\<^sub>L)) +\<^sub>L ((snd\<^sub>L ;\<^sub>L fst\<^sub>L) +\<^sub>L (snd\<^sub>L ;\<^sub>L snd\<^sub>L))" in exI)
    apply (auto)
     apply (auto intro!: plus_vwb_lens comp_vwb_lens fst_vwb_lens snd_vwb_lens lens_indep_right_comp)
       apply (auto intro!: lens_indepI simp add: lens_comp_def lens_plus_def fst_lens_def snd_lens_def)
     apply (auto simp add: lens_prod_def lens_plus_def lens_comp_def fst_lens_def snd_lens_def prod.case_eq_if comp_def)[1]
    apply (rule ext, rule ext, auto simp add: lens_prod_def prod.case_eq_if)
  done
qed

subsection \<open>Bijective Lens Equivalences\<close>
  
text \<open>A bijective lens, like a bijective function, is its own inverse. Thus, if we compose its inverse
  with itself we get @{term "1\<^sub>L"}.\<close>
  
lemma bij_lens_inv_left:
  "bij_lens X \<Longrightarrow> inv\<^sub>L X ;\<^sub>L X = 1\<^sub>L"
  by (auto simp add: lens_inv_def lens_comp_def comp_def id_lens_def, rule ext, auto)

lemma bij_lens_inv_right:
  "bij_lens X \<Longrightarrow> X ;\<^sub>L inv\<^sub>L X = 1\<^sub>L"
  by (auto simp add: lens_inv_def lens_comp_def comp_def id_lens_def, rule ext, auto)

text \<open>The following important results shows that bijective lenses are precisely those that are 
  equivalent to identity. In other words, a bijective lens views all of the source type.\<close>

lemma bij_lens_equiv_id:
  "bij_lens X \<longleftrightarrow> X \<approx>\<^sub>L 1\<^sub>L"
  apply (auto)
   apply (rule lens_equivI)
    apply (simp_all add: sublens_def)
   apply (rule_tac x="lens_inv X" in exI)
   apply (simp add: bij_lens_inv_left lens_inv_bij)
  apply (auto simp add: lens_equiv_def sublens_def id_lens_def lens_comp_def comp_def)
  apply (unfold_locales)
   apply (simp)
  apply (simp)
  apply (metis (no_types, lifting) vwb_lens_wb wb_lens_weak weak_lens.put_get)
done

text \<open>For this reason, by transitivity, any two bijective lenses with the same source type must be equivalent.\<close>
  
lemma bij_lens_equiv:
  "\<lbrakk> bij_lens X; X \<approx>\<^sub>L Y \<rbrakk> \<Longrightarrow> bij_lens Y"
  by (meson bij_lens_equiv_id lens_equiv_def sublens_trans)

text \<open>We can also show that the identity lens @{term "1\<^sub>L"} is unique. That is to say it is the only
  lens which when compose with $Y$ will yield $Y$.\<close>
    
lemma lens_id_unique:
  "weak_lens Y \<Longrightarrow> Y = X ;\<^sub>L Y \<Longrightarrow> X = 1\<^sub>L"
  apply (cases Y)
  apply (cases X)
  apply (auto simp add: lens_comp_def comp_def id_lens_def fun_eq_iff)
   apply (metis select_convs(1) weak_lens.create_get)
  apply (metis select_convs(1) select_convs(2) weak_lens.put_get)
done

text \<open>Consequently, if composition of two lenses $X$ and $Y$ yields @{text "1\<^sub>L"}, then both
  of the composed lenses must be bijective.\<close>
  
lemma bij_lens_via_comp_id_left:
  "\<lbrakk> wb_lens X; wb_lens Y; X ;\<^sub>L Y = 1\<^sub>L \<rbrakk> \<Longrightarrow> bij_lens X"
  apply (cases Y)
  apply (cases X)
  apply (auto simp add: lens_comp_def comp_def id_lens_def fun_eq_iff)
  apply (unfold_locales)
   apply (simp_all)
   using vwb_lens_wb wb_lens_weak weak_lens.put_get apply fastforce
  apply (metis select_convs(1) select_convs(2) wb_lens_weak weak_lens.put_get)
done

lemma bij_lens_via_comp_id_right:
  "\<lbrakk> wb_lens X; wb_lens Y; X ;\<^sub>L Y = 1\<^sub>L \<rbrakk> \<Longrightarrow> bij_lens Y"
  apply (cases Y)
  apply (cases X)
  apply (auto simp add: lens_comp_def comp_def id_lens_def fun_eq_iff)
  apply (unfold_locales)
   apply (simp_all)
   using vwb_lens_wb wb_lens_weak weak_lens.put_get apply fastforce
  apply (metis select_convs(1) select_convs(2) wb_lens_weak weak_lens.put_get)
done

text \<open>Importantly, an equivalence between two lenses can be demonstrated by showing that one lens
  can be converted to the other by application of a suitable bijective lens $Z$. This $Z$ lens
  converts the view type of one to the view type of the other.\<close>

lemma lens_equiv_via_bij:
  assumes "bij_lens Z" "X = Z ;\<^sub>L Y"
  shows "X \<approx>\<^sub>L Y"
  using assms
  apply (auto simp add: lens_equiv_def sublens_def)
   using bij_lens_vwb apply blast
  apply (rule_tac x="lens_inv Z" in exI)
  apply (auto simp add: lens_comp_assoc bij_lens_inv_left)
   using bij_lens_vwb lens_inv_bij apply blast
  apply (simp add: bij_lens_inv_left lens_comp_assoc[THEN sym])
done

text \<open>Indeed, we actually have a stronger result than this -- the equivalent lenses are precisely
  those than can be converted to one another through a suitable bijective lens. Bijective lenses
  can thus be seen as a special class of "adapter" lens.\<close>
  
lemma lens_equiv_iff_bij:
  assumes "weak_lens Y"
  shows "X \<approx>\<^sub>L Y \<longleftrightarrow> (\<exists> Z. bij_lens Z \<and> X = Z ;\<^sub>L Y)"
  apply (rule iffI)
   apply (auto simp add: lens_equiv_def sublens_def lens_id_unique)[1]
   apply (rename_tac Z\<^sub>1 Z\<^sub>2)
   apply (rule_tac x="Z\<^sub>1" in exI)
   apply (simp)
   apply (subgoal_tac "Z\<^sub>2 ;\<^sub>L Z\<^sub>1 = 1\<^sub>L")
    apply (meson bij_lens_via_comp_id_right vwb_lens_wb)
   apply (metis assms lens_comp_assoc lens_id_unique)
  using lens_equiv_via_bij apply blast
done

subsection \<open>Lens Override Laws\<close>
  
text \<open>The following laws are analogus to the equivalent laws for functions.\<close>
  
lemma lens_override_id [simp]:
  "S\<^sub>1 \<oplus>\<^sub>L S\<^sub>2 on 1\<^sub>L = S\<^sub>2"
  by (simp add: lens_override_def id_lens_def)

lemma lens_override_unit [simp]:
  "S\<^sub>1 \<oplus>\<^sub>L S\<^sub>2 on 0\<^sub>L = S\<^sub>1"
  by (simp add: lens_override_def zero_lens_def)

lemma lens_override_overshadow:
  assumes "mwb_lens Y"  "X \<subseteq>\<^sub>L Y"
  shows "(S\<^sub>1 \<oplus>\<^sub>L S\<^sub>2 on X) \<oplus>\<^sub>L S\<^sub>3 on Y = S\<^sub>1 \<oplus>\<^sub>L S\<^sub>3 on Y"
  using assms by (simp add: lens_override_def sublens_put_put)

lemma lens_override_plus:
  "X \<bowtie> Y \<Longrightarrow> S\<^sub>1 \<oplus>\<^sub>L S\<^sub>2 on (X +\<^sub>L Y) = (S\<^sub>1 \<oplus>\<^sub>L S\<^sub>2 on X) \<oplus>\<^sub>L S\<^sub>2 on Y"
  by (simp add: lens_indep_comm lens_override_def lens_plus_def)
end