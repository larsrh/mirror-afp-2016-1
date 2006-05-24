(*  Title:       CoreC++
    ID:          $Id: DefAss.thy,v 1.3 2006-05-24 01:09:41 lsf37 Exp $
    Author:      Tobias Nipkow, Daniel Wasserrab
    Maintainer:  Daniel Wasserrab <wasserra at fmi.uni-passau.de>
*)


header {* Definite assignment *}

theory DefAss imports BigStep begin

subsection "Hypersets"

types hyperset = "vname set option"

constdefs
  hyperUn :: "hyperset \<Rightarrow> hyperset \<Rightarrow> hyperset"   (infixl "\<squnion>" 65)
  "A \<squnion> B  \<equiv>  case A of None \<Rightarrow> None
                 | \<lfloor>A\<rfloor> \<Rightarrow> (case B of None \<Rightarrow> None | \<lfloor>B\<rfloor> \<Rightarrow> \<lfloor>A \<union> B\<rfloor>)"

  hyperInt :: "hyperset \<Rightarrow> hyperset \<Rightarrow> hyperset"   (infixl "\<sqinter>" 70)
  "A \<sqinter> B  \<equiv>  case A of None \<Rightarrow> B
                 | \<lfloor>A\<rfloor> \<Rightarrow> (case B of None \<Rightarrow> \<lfloor>A\<rfloor> | \<lfloor>B\<rfloor> \<Rightarrow> \<lfloor>A \<inter> B\<rfloor>)"

  hyperDiff1 :: "hyperset \<Rightarrow> vname \<Rightarrow> hyperset"   (infixl "\<ominus>" 65)
  "A \<ominus> a  \<equiv>  case A of None \<Rightarrow> None | \<lfloor>A\<rfloor> \<Rightarrow> \<lfloor>A - {a}\<rfloor>"

 hyper_isin :: "vname \<Rightarrow> hyperset \<Rightarrow> bool"   (infix "\<in>\<in>" 50)
"a \<in>\<in> A  \<equiv>  case A of None \<Rightarrow> True | \<lfloor>A\<rfloor> \<Rightarrow> a \<in> A"

  hyper_subset :: "hyperset \<Rightarrow> hyperset \<Rightarrow> bool"   (infix "\<sqsubseteq>" 50)
  "A \<sqsubseteq> B  \<equiv>  case B of None \<Rightarrow> True
                 | \<lfloor>B\<rfloor> \<Rightarrow> (case A of None \<Rightarrow> False | \<lfloor>A\<rfloor> \<Rightarrow> A \<subseteq> B)"

lemmas hyperset_defs =
 hyperUn_def hyperInt_def hyperDiff1_def hyper_isin_def hyper_subset_def

lemma [simp]: "\<lfloor>{}\<rfloor> \<squnion> A = A  \<and>  A \<squnion> \<lfloor>{}\<rfloor> = A"
by(simp add:hyperset_defs)

lemma [simp]: "\<lfloor>A\<rfloor> \<squnion> \<lfloor>B\<rfloor> = \<lfloor>A \<union> B\<rfloor> \<and> \<lfloor>A\<rfloor> \<ominus> a = \<lfloor>A - {a}\<rfloor>"
by(simp add:hyperset_defs)

lemma [simp]: "None \<squnion> A = None \<and> A \<squnion> None = None"
by(simp add:hyperset_defs)

lemma [simp]: "a \<in>\<in> None \<and> None \<ominus> a = None"
by(simp add:hyperset_defs)

lemma hyperUn_assoc: "(A \<squnion> B) \<squnion> C = A \<squnion> (B \<squnion> C)"
by(simp add:hyperset_defs Un_assoc)

lemma hyper_insert_comm: "A \<squnion> \<lfloor>{a}\<rfloor> = \<lfloor>{a}\<rfloor> \<squnion> A \<and> A \<squnion> (\<lfloor>{a}\<rfloor> \<squnion> B) = \<lfloor>{a}\<rfloor> \<squnion> (A \<squnion> B)"
by(simp add:hyperset_defs)


subsection "Definite assignment"

consts
 \<A>  :: "expr \<Rightarrow> hyperset"
 \<A>s :: "expr list \<Rightarrow> hyperset"
 \<D>  :: "expr \<Rightarrow> hyperset \<Rightarrow> bool"
 \<D>s :: "expr list \<Rightarrow> hyperset \<Rightarrow> bool"

primrec
"\<A> (new C) = \<lfloor>{}\<rfloor>"
"\<A> (Cast C e) = \<A> e"
"\<A> (\<lparr>C\<rparr>e) = \<A> e"
"\<A> (Val v) = \<lfloor>{}\<rfloor>"
"\<A> (e\<^isub>1 \<guillemotleft>bop\<guillemotright> e\<^isub>2) = \<A> e\<^isub>1 \<squnion> \<A> e\<^isub>2"
"\<A> (Var V) = \<lfloor>{}\<rfloor>"
"\<A> (LAss V e) = \<lfloor>{V}\<rfloor> \<squnion> \<A> e"
"\<A> (e\<bullet>F{Cs}) = \<A> e"
"\<A> (e\<^isub>1\<bullet>F{Cs}:=e\<^isub>2) = \<A> e\<^isub>1 \<squnion> \<A> e\<^isub>2"
"\<A> (e\<bullet>M(es)) = \<A> e \<squnion> \<A>s es"
"\<A> ({V:T; e}) = \<A> e \<ominus> V"
"\<A> (e\<^isub>1;;e\<^isub>2) = \<A> e\<^isub>1 \<squnion> \<A> e\<^isub>2"
"\<A> (if (e) e\<^isub>1 else e\<^isub>2) =  \<A> e \<squnion> (\<A> e\<^isub>1 \<sqinter> \<A> e\<^isub>2)"
"\<A> (while (b) e) = \<A> b"
"\<A> (throw e) = None"
(*"\<A> (try e\<^isub>1 catch(C V) e\<^isub>2) = \<A> e\<^isub>1 \<sqinter> (\<A> e\<^isub>2 \<ominus> V)"*)

"\<A>s ([]) = \<lfloor>{}\<rfloor>"
"\<A>s (e#es) = \<A> e \<squnion> \<A>s es"

primrec
"\<D> (new C) A = True"
"\<D> (Cast C e) A = \<D> e A"
"\<D> (\<lparr>C\<rparr>e) A = \<D> e A"
"\<D> (Val v) A = True"
"\<D> (e\<^isub>1 \<guillemotleft>bop\<guillemotright> e\<^isub>2) A = (\<D> e\<^isub>1 A \<and> \<D> e\<^isub>2 (A \<squnion> \<A> e\<^isub>1))"
"\<D> (Var V) A = (V \<in>\<in> A)"
"\<D> (LAss V e) A = \<D> e A"
"\<D> (e\<bullet>F{Cs}) A = \<D> e A"
"\<D> (e\<^isub>1\<bullet>F{Cs}:=e\<^isub>2) A = (\<D> e\<^isub>1 A \<and> \<D> e\<^isub>2 (A \<squnion> \<A> e\<^isub>1))"
"\<D> (e\<bullet>M(es)) A = (\<D> e A \<and> \<D>s es (A \<squnion> \<A> e))"
"\<D> ({V:T; e}) A = \<D> e (A \<ominus> V)"
"\<D> (e\<^isub>1;;e\<^isub>2) A = (\<D> e\<^isub>1 A \<and> \<D> e\<^isub>2 (A \<squnion> \<A> e\<^isub>1))"
"\<D> (if (e) e\<^isub>1 else e\<^isub>2) A =
  (\<D> e A \<and> \<D> e\<^isub>1 (A \<squnion> \<A> e) \<and> \<D> e\<^isub>2 (A \<squnion> \<A> e))"
"\<D> (while (e) c) A = (\<D> e A \<and> \<D> c (A \<squnion> \<A> e))"
"\<D> (throw e) A = \<D> e A"
(*"\<D> (try e\<^isub>1 catch(C V) e\<^isub>2) A = (\<D> e\<^isub>1 A \<and> \<D> e\<^isub>2 (A \<squnion> \<lfloor>{V}\<rfloor>))"*)

"\<D>s ([]) A = True"
"\<D>s (e#es) A = (\<D> e A \<and> \<D>s es (A \<squnion> \<A> e))"

lemma As_map_Val[simp]: "\<A>s (map Val vs) = \<lfloor>{}\<rfloor>"
by (induct vs) simp_all

lemma D_append[iff]: "\<And>A. \<D>s (es @ es') A = (\<D>s es A \<and> \<D>s es' (A \<squnion> \<A>s es))"
by (induct es type:list) (auto simp:hyperUn_assoc)


lemma A_fv: "\<And>A. \<A> e = \<lfloor>A\<rfloor> \<Longrightarrow> A \<subseteq> fv e"
and  "\<And>A. \<A>s es = \<lfloor>A\<rfloor> \<Longrightarrow> A \<subseteq> fvs es"

apply(induct e and es)
apply (simp_all add:hyperset_defs)
apply blast+
done



lemma sqUn_lem: "A \<sqsubseteq> A' \<Longrightarrow> A \<squnion> B \<sqsubseteq> A' \<squnion> B"
by(simp add:hyperset_defs) blast

lemma diff_lem: "A \<sqsubseteq> A' \<Longrightarrow> A \<ominus> b \<sqsubseteq> A' \<ominus> b"
by(simp add:hyperset_defs) blast

(* This order of the premises avoids looping of the simplifier *)
lemma D_mono: "\<And>A A'. A \<sqsubseteq> A' \<Longrightarrow> \<D> e A \<Longrightarrow> \<D> (e::expr) A'"
and Ds_mono: "\<And>A A'. A \<sqsubseteq> A' \<Longrightarrow> \<D>s es A \<Longrightarrow> \<D>s (es::expr list) A'"

apply(induct e and es)
apply simp
apply simp
apply simp
apply simp
apply simp apply (iprover dest:sqUn_lem)
apply (fastsimp simp add:hyperset_defs)
apply simp
apply simp
apply simp apply (iprover dest:sqUn_lem)
apply simp apply (iprover dest:sqUn_lem)
apply simp apply (iprover dest:diff_lem)
apply simp apply (iprover dest:sqUn_lem)
apply simp apply (iprover dest:sqUn_lem)
apply simp apply (iprover dest:sqUn_lem)
apply simp
apply simp 
apply simp
apply (iprover dest:sqUn_lem)
done


(* And this is the order of premises preferred during application: *)
lemma D_mono': "\<D> e A \<Longrightarrow> A \<sqsubseteq> A' \<Longrightarrow> \<D> e A'"
and Ds_mono': "\<D>s es A \<Longrightarrow> A \<sqsubseteq> A' \<Longrightarrow> \<D>s es A'"
by(blast intro:D_mono, blast intro:Ds_mono)





end
