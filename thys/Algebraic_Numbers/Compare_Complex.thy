(*  
    Author:      René Thiemann 
                 Akihisa Yamada
    License:     BSD
*)
subsection \<open>Compare Instance for Complex Numbers\<close>

text \<open>We define some code equations for complex numbers, provide a comparator for complex
  numbers, and register complex numbers for the container framework.\<close>

theory Compare_Complex
imports 
  Complex
  "../Polynomial_Interpolation/Missing_Unsorted"
  "../Deriving/Comparator_Generator/Compare_Real"
  "../Containers/Set_Impl"
begin

lemma in_reals_code[code_unfold]: "((x :: complex) \<in> \<real>) = (Im x = 0)" 
  by (rule complex_is_Real_iff)

definition is_norm_1 :: "complex \<Rightarrow> bool" where
  "is_norm_1 z = ((Re z)\<^sup>2 + (Im z)\<^sup>2 = 1)"

lemma is_norm_1[simp]: "is_norm_1 x = (norm x = 1)"
  unfolding is_norm_1_def complex_norm_def by simp

definition is_norm_le_1 :: "complex \<Rightarrow> bool" where
  "is_norm_le_1 z = ((Re z)\<^sup>2 + (Im z)\<^sup>2 \<le> 1)"

lemma is_norm_le_1[simp]: "is_norm_le_1 x = (norm x \<le> 1)"
  unfolding is_norm_le_1_def complex_norm_def by simp

instantiation complex :: finite_UNIV
begin
definition "finite_UNIV = Phantom(complex) False"
instance
  by (intro_classes, unfold finite_UNIV_complex_def, simp add: infinite_UNIV_char_0)
end

instantiation complex :: compare
begin
definition compare_complex :: "complex \<Rightarrow> complex \<Rightarrow> order" where
  "compare_complex x y = compare (Re x, Im x) (Re y, Im y)"

instance 
proof (intro_classes, unfold_locales; unfold compare_complex_def)
  fix x y z :: complex
  let ?c = "compare :: (real \<times> real) comparator"
  interpret comparator ?c by (rule comparator_compare)
  show "invert_order (?c (Re x, Im x) (Re y, Im y)) = ?c (Re y, Im y) (Re x, Im x)"
    by (rule sym)
  {
    assume "?c (Re x, Im x) (Re y, Im y) = Lt"
      "?c (Re y, Im y) (Re z, Im z) = Lt"
    thus "?c (Re x, Im x) (Re z, Im z) = Lt"
      by (rule trans)
  }
  {
    assume "?c (Re x, Im x) (Re y, Im y) = Eq"
    from weak_eq[OF this] show "x = y" unfolding complex_eq_iff by auto
  }
qed
end

derive (eq) ceq complex real
derive (compare) ccompare complex
derive (compare) ccompare real
derive (dlist) set_impl complex real
 
end
