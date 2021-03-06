(* Author: Alexander Bentkamp, Universität des Saarlandes *)

section \<open>CP-Rank and Matrix Rank\<close>

theory DL_Rank_CP_Rank
imports Tensor_Rank DL_Rank Tensor_Matricization DL_Submatrix DL_Missing_Vector_Space
begin

abbreviation "mrank A == vec_space.rank (dim\<^sub>r A) A"

no_notation "normal_rel"  (infixl "\<lhd>" 60)

lemma lookup_order1_prod:
assumes "\<And>B. B\<in>set Bs \<Longrightarrow> Tensor.order B = 1" 
assumes "is \<lhd> dims (prod_list Bs)"
shows "lookup (prod_list Bs) is = prod_list (map (\<lambda>(i,B). lookup B [i]) (zip is Bs))"
using assms proof (induction Bs arbitrary:"is")
  case Nil
  then show ?case unfolding "prod_list.Nil" unfolding zip.simps tensor_one_def 
    by (metis (no_types, lifting) dims_tensor_from_lookup length_greater_0_conv length_map prod_list.Nil 
    lookup_tensor_from_lookup tensor_one_def tensor_one_from_lookup)
next
  case (Cons B Bs "is'")
  then obtain i "is" where "is' = i # is" 
    by (metis append_is_Nil_conv dims_tensor_prod length_0_conv list.set_intros(1) prod_list.Cons valid_index.simps zero_neq_one)
  have "Tensor.order B = 1" using Cons by auto
  then have valid1:"[i] \<lhd> dims B"
    using `is' \<lhd> dims (prod_list (B # Bs))`[unfolded prod_list.Cons dims_tensor_prod `is' = i # is`] 
    by (metis One_nat_def Suc_length_conv hd_append2 length_0_conv list.sel(1) list.simps(3) valid_index.Nil valid_index.simps)
  have valid2:"is \<lhd> dims (prod_list Bs)" 
    using `is' \<lhd> dims (prod_list (B # Bs))`[unfolded prod_list.Cons dims_tensor_prod `is' = i # is`] `Tensor.order B = 1`
    by (metis One_nat_def Suc_length_conv append_eq_Cons_conv length_0_conv list.sel(3) list.simps(3) self_append_conv2 valid_indexE)
  show ?case unfolding `is' = i # is` List.zip_Cons_Cons List.list.map(2) prod_list.Cons 
    lookup_tensor_prod[OF valid1 valid2, simplified] by (simp add: Cons.IH Cons.prems(1) valid2)
qed

lemma matricize_cprank_max1:
fixes A::"'a::field tensor"
assumes "cprank_max1 A"
shows "mrank (matricize I A) \<le> 1" 
proof -
  obtain Bs a where "\<And>B. B \<in> set Bs \<Longrightarrow> Tensor.order B = 1" "a \<cdot> prod_list Bs = A"
    using cprank_max1_prod_listE assms by metis
  def row_factor == "\<lambda>ris. a * (prod_list (map (\<lambda>(i,B). lookup B [i]) (zip ris (sublist Bs I))))"
  def col_factor == "\<lambda>cis. (prod_list (map (\<lambda>(i,B). lookup B [i]) (zip cis (sublist Bs (-I)))))"
  have "\<And>is. is \<lhd> dims A \<Longrightarrow> lookup A is = row_factor (sublist is I) * col_factor (sublist is (-I))"
  proof -
    fix "is" assume "is \<lhd> dims A"
    then have "lookup A is = a * (prod_list (map (\<lambda>(i,B). lookup B [i]) (zip is Bs)))" 
      using lookup_order1_prod[OF `\<And>B. B \<in> set Bs \<Longrightarrow> Tensor.order B = 1`] lookup_smult 
      using \<open>a \<cdot> prod_list Bs = A\<close> dims_smult by fastforce
    also have "... = a * (prod_list (map (\<lambda>(i,B). lookup B [i]) (sublist (zip is Bs) I))) * 
                         (prod_list (map (\<lambda>(i,B). lookup B [i]) (sublist (zip is Bs) (-I))))"
      using prod_list_complementary_sublists by auto
    also have "... = row_factor (sublist is I) * col_factor (sublist is (-I))"
      using sublist_zip row_factor_def col_factor_def by metis
    finally show "lookup A is = row_factor (sublist is I) * col_factor (sublist is (-I))" .
  qed
  def row_factor' == "\<lambda>r. row_factor (digit_encode (sublist (Tensor.dims A) I) r)"
  def col_factor' == "\<lambda>c. col_factor (digit_encode (sublist (Tensor.dims A) (-I)) c)"
  have "\<And>r c. r<dim\<^sub>r (matricize I A) \<Longrightarrow> c<dim\<^sub>c (matricize I A) \<Longrightarrow> matricize I A $$ (r,c) = row_factor' r * col_factor' c"
  proof -
    fix r c assume "r<dim\<^sub>r (matricize I A)" "c<dim\<^sub>c (matricize I A)"
    then have "matricize I A $$ (r,c) = Tensor.lookup A (weave I 
      (digit_encode (sublist (Tensor.dims A) I) r) 
      (digit_encode (sublist (Tensor.dims A) (-I)) c)
    )" unfolding dims_matricize unfolding matricize_def by simp
    also have "... = row_factor' r * col_factor' c" 
      using  \<open>\<And>is. is \<lhd> dims A \<Longrightarrow> lookup A is = row_factor (sublist is I) * col_factor (sublist is (- I))\<close>
      valid_index_weave[OF
      digit_encode_valid_index[OF \<open>r < dim\<^sub>r (matricize I A)\<close>[unfolded dims_matricize]]
      digit_encode_valid_index[OF \<open>c < dim\<^sub>c (matricize I A)\<close>[unfolded dims_matricize]]]
      valid_index_weave(2) valid_index_weave(3) row_factor'_def col_factor'_def by metis
    finally show "matricize I A $$ (r,c) = row_factor' r * col_factor' c" .
  qed
  then show ?thesis using vec_space.rank_le_1_product_entries[of "matricize I A"] by blast
qed

lemma matrix_rank_le_cprank_max:
fixes A :: "('a::field) tensor"
assumes "cprank_max r A"
shows "mrank (matricize I A) \<le> r"
using assms 
proof (induction rule:cprank_max.induct)
  fix ds :: "nat list"
  have "matricize I (tensor0 ds) = \<zero>\<^sub>m (dim\<^sub>r (matricize I (tensor0 ds))) (dim\<^sub>c (matricize I (tensor0 ds)))"
    using matricize_0 by auto
  then show "mrank (matricize I (tensor0 ds)) \<le> 0" 
    using eq_imp_le vec_space.rank_0I by metis
next
  fix A B::"'a tensor" and j::nat
  assume "dims A = dims B"
  assume "cprank_max1 A"
  assume "mrank (matricize I B) \<le> j"
  have "mrank (matricize I A) \<le> 1" using `cprank_max1 A` matricize_cprank_max1 by auto
  have "mrank (matricize I (A + B)) \<le> mrank (matricize I A) + mrank (matricize I B)" 
    using matricize_add vec_space.rank_subadditive dims_matricize 
    mat_carrierI mat_index_add(2) `dims A = dims B` by metis
  then show "mrank (matricize I (A + B)) \<le> Suc j"
    using \<open>mrank (matricize I A) \<le> 1\<close> `mrank (matricize I B) \<le> j` by linarith
qed

lemma matrix_rank_le_cp_rank:
fixes A :: "('a::field) tensor"
shows "mrank (matricize I A) \<le> cprank A"
using matrix_rank_le_cprank_max using cprank_max_cprank by auto
  
end
