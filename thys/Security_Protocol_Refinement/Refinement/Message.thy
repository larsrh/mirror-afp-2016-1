(*******************************************************************************  

  Title:      HOL/Auth/Message
  Author:     Lawrence C Paulson, Cambridge University Computer Laboratory
  Copyright   1996  University of Cambridge

  Datatypes of agents and messages;
  Inductive relations "parts", "analz" and "synth"

********************************************************************************

  Module:  Refinement/Message.thy (Isabelle/HOL 2016-1)
  ID:      $Id: Message.thy 133856 2017-03-20 18:05:54Z csprenge $
  Edited:  Christoph Sprenger <sprenger@inf.ethz.ch>, ETH Zurich

  Integrated and adapted for security protocol refinement

*******************************************************************************)

section {*Theory of Agents and Messages for Security Protocols*}

theory Message imports Keys begin

(*Needed occasionally with spy_analz_tac, e.g. in analz_insert_Key_newK*)
lemma Un_idem_collapse [simp]: "A \<union> (B \<union> A) = B \<union> A"
by blast

datatype
     msg = Agent  agent     --{*Agent names*}
         | Number nat       --{*Ordinary integers, timestamps, ...*}
         | Nonce  nonce     --{*Unguessable nonces*}
         | Key    key       --{*Crypto keys*}
         | Hash   msg       --{*Hashing*}
         | MPair  msg msg   --{*Compound messages*}
         | Crypt  key msg   --{*Encryption, public- or shared-key*}


text{*Concrete syntax: messages appear as {|A,B,NA|}, etc...*}

syntax
  "_MTuple"      :: "['a, args] => 'a * 'b"       ("(2{|_,/ _|})")

syntax (xsymbols)
  "_MTuple"      :: "['a, args] => 'a * 'b"       ("(2\<lbrace>_,/ _\<rbrace>)")

translations
  "{|x, y, z|}"   == "{|x, {|y, z|}|}"
  "{|x, y|}"      == "CONST MPair x y"


definition
  HPair :: "[msg,msg] \<Rightarrow> msg"                       ("(4Hash[_] /_)" [0, 1000])
where
  --{*Message Y paired with a MAC computed with the help of X*}
  "Hash[X] Y \<equiv> {| Hash{|X,Y|}, Y|}"

definition
  keysFor :: "msg set \<Rightarrow> key set"
where
    --{*Keys useful to decrypt elements of a message set*}
  "keysFor H \<equiv> invKey ` {K. \<exists>X. Crypt K X \<in> H}"


subsubsection{*Inductive Definition of All Parts" of a Message*}

inductive_set
  parts :: "msg set => msg set"
  for H :: "msg set"
  where
    Inj [intro]:               "X \<in> H ==> X \<in> parts H"
  | Fst:         "{|X,Y|}   \<in> parts H ==> X \<in> parts H"
  | Snd:         "{|X,Y|}   \<in> parts H ==> Y \<in> parts H"
  | Body:        "Crypt K X \<in> parts H ==> X \<in> parts H"


text{*Monotonicity*}
lemma parts_mono: "G \<subseteq> H ==> parts(G) \<subseteq> parts(H)"
apply auto
apply (erule parts.induct) 
apply (blast dest: parts.Fst parts.Snd parts.Body)+
done


text{*Equations hold because constructors are injective.*}
lemma Other_image_eq [simp]: "(Agent x \<in> Agent`A) = (x:A)"
by auto

lemma Key_image_eq [simp]: "(Key x \<in> Key`A) = (x\<in>A)"
by auto

lemma Nonce_Key_image_eq [simp]: "(Nonce x \<notin> Key`A)"
by auto



subsection{*keysFor operator*}

lemma keysFor_empty [simp]: "keysFor {} = {}"
by (unfold keysFor_def, blast)

lemma keysFor_Un [simp]: "keysFor (H \<union> H') = keysFor H \<union> keysFor H'"
by (unfold keysFor_def, blast)

lemma keysFor_UN [simp]: "keysFor (\<Union>i\<in>A. H i) = (\<Union>i\<in>A. keysFor (H i))"
by (unfold keysFor_def, blast)

text{*Monotonicity*}
lemma keysFor_mono: "G \<subseteq> H ==> keysFor(G) \<subseteq> keysFor(H)"
by (unfold keysFor_def, blast)

lemma keysFor_insert_Agent [simp]: "keysFor (insert (Agent A) H) = keysFor H"
by (unfold keysFor_def, auto)

lemma keysFor_insert_Nonce [simp]: "keysFor (insert (Nonce N) H) = keysFor H"
by (unfold keysFor_def, auto)

lemma keysFor_insert_Number [simp]: "keysFor (insert (Number N) H) = keysFor H"
by (unfold keysFor_def, auto)

lemma keysFor_insert_Key [simp]: "keysFor (insert (Key K) H) = keysFor H"
by (unfold keysFor_def, auto)

lemma keysFor_insert_Hash [simp]: "keysFor (insert (Hash X) H) = keysFor H"
by (unfold keysFor_def, auto)

lemma keysFor_insert_MPair [simp]: "keysFor (insert {|X,Y|} H) = keysFor H"
by (unfold keysFor_def, auto)

lemma keysFor_insert_Crypt [simp]: 
    "keysFor (insert (Crypt K X) H) = insert (invKey K) (keysFor H)"
by (unfold keysFor_def, auto)

lemma keysFor_image_Key [simp]: "keysFor (Key`E) = {}"
by (unfold keysFor_def, auto)

lemma Crypt_imp_invKey_keysFor: "Crypt K X \<in> H ==> invKey K \<in> keysFor H"
by (unfold keysFor_def, blast)


subsection{*Inductive relation "parts"*}

lemma MPair_parts:
     "[| {|X,Y|} \<in> parts H;        
         [| X \<in> parts H; Y \<in> parts H |] ==> P |] ==> P"
by (blast dest: parts.Fst parts.Snd) 

declare MPair_parts [elim!]  parts.Body [dest!]
text{*NB These two rules are UNSAFE in the formal sense, as they discard the
     compound message.  They work well on THIS FILE.  
  @{text MPair_parts} is left as SAFE because it speeds up proofs.
  The Crypt rule is normally kept UNSAFE to avoid breaking up certificates.*}

lemma parts_increasing: "H \<subseteq> parts(H)"
by blast

lemmas parts_insertI = subset_insertI [THEN parts_mono, THEN subsetD]

lemma parts_empty [simp]: "parts{} = {}"
apply safe
apply (erule parts.induct, blast+)
done

lemma parts_emptyE [elim!]: "X\<in> parts{} ==> P"
by simp

text{*WARNING: loops if H = {Y}, therefore must not be repeated!*}
lemma parts_singleton: "X\<in> parts H ==> \<exists>Y\<in>H. X\<in> parts {Y}"
by (erule parts.induct, fast+)


subsubsection{*Unions *}

lemma parts_Un_subset1: "parts(G) \<union> parts(H) \<subseteq> parts(G \<union> H)"
by (intro Un_least parts_mono Un_upper1 Un_upper2)

lemma parts_Un_subset2: "parts(G \<union> H) \<subseteq> parts(G) \<union> parts(H)"
apply (rule subsetI)
apply (erule parts.induct, blast+)
done

lemma parts_Un [simp]: "parts(G \<union> H) = parts(G) \<union> parts(H)"
by (intro equalityI parts_Un_subset1 parts_Un_subset2)

lemma parts_insert: "parts (insert X H) = parts {X} \<union> parts H"
apply (subst insert_is_Un [of _ H])
apply (simp only: parts_Un)
done

text{*TWO inserts to avoid looping.  This rewrite is better than nothing.
  Not suitable for Addsimps: its behaviour can be strange.*}
lemma parts_insert2:
     "parts (insert X (insert Y H)) = parts {X} \<union> parts {Y} \<union> parts H"
apply (simp add: Un_assoc)
apply (simp add: parts_insert [symmetric])
done

lemma parts_UN_subset1: "(\<Union>x\<in>A. parts(H x)) \<subseteq> parts(\<Union>x\<in>A. H x)"
by (intro UN_least parts_mono UN_upper)

lemma parts_UN_subset2: "parts(\<Union>x\<in>A. H x) \<subseteq> (\<Union>x\<in>A. parts(H x))"
apply (rule subsetI)
apply (erule parts.induct, blast+)
done

lemma parts_UN [simp]: "parts(\<Union>x\<in>A. H x) = (\<Union>x\<in>A. parts(H x))"
by (intro equalityI parts_UN_subset1 parts_UN_subset2)

text{*Added to simplify arguments to parts, analz and synth.
  NOTE: the UN versions are no longer used!*}


text{*This allows @{text blast} to simplify occurrences of 
  @{term "parts(G\<union>H)"} in the assumption.*}
lemmas in_parts_UnE = parts_Un [THEN equalityD1, THEN subsetD, THEN UnE] 
declare in_parts_UnE [elim!]


lemma parts_insert_subset: "insert X (parts H) \<subseteq> parts(insert X H)"
by (blast intro: parts_mono [THEN [2] rev_subsetD])

subsubsection{*Idempotence and transitivity *}

lemma parts_partsD [dest!]: "X\<in> parts (parts H) ==> X\<in> parts H"
by (erule parts.induct, blast+)

lemma parts_idem [simp]: "parts (parts H) = parts H"
by blast

lemma parts_subset_iff [simp]: "(parts G \<subseteq> parts H) = (G \<subseteq> parts H)"
apply (rule iffI)
apply (iprover intro: subset_trans parts_increasing)  
apply (frule parts_mono, simp) 
done

lemma parts_trans: "[| X\<in> parts G;  G \<subseteq> parts H |] ==> X\<in> parts H"
by (drule parts_mono, blast)

text{*Cut*}
lemma parts_cut:
     "[| Y\<in> parts (insert X G);  X\<in> parts H |] ==> Y\<in> parts (G \<union> H)" 
by (blast intro: parts_trans) 


lemma parts_cut_eq [simp]: "X\<in> parts H ==> parts (insert X H) = parts H"
by (force dest!: parts_cut intro: parts_insertI)


subsubsection{*Rewrite rules for pulling out atomic messages *}

lemmas parts_insert_eq_I = equalityI [OF subsetI parts_insert_subset]


lemma parts_insert_Agent [simp]:
     "parts (insert (Agent agt) H) = insert (Agent agt) (parts H)"
apply (rule parts_insert_eq_I) 
apply (erule parts.induct, auto) 
done

lemma parts_insert_Nonce [simp]:
     "parts (insert (Nonce N) H) = insert (Nonce N) (parts H)"
apply (rule parts_insert_eq_I) 
apply (erule parts.induct, auto) 
done

lemma parts_insert_Number [simp]:
     "parts (insert (Number N) H) = insert (Number N) (parts H)"
apply (rule parts_insert_eq_I) 
apply (erule parts.induct, auto) 
done

lemma parts_insert_Key [simp]:
     "parts (insert (Key K) H) = insert (Key K) (parts H)"
apply (rule parts_insert_eq_I) 
apply (erule parts.induct, auto) 
done

lemma parts_insert_Hash [simp]:
     "parts (insert (Hash X) H) = insert (Hash X) (parts H)"
apply (rule parts_insert_eq_I) 
apply (erule parts.induct, auto) 
done

lemma parts_insert_Crypt [simp]:
     "parts (insert (Crypt K X) H) = insert (Crypt K X) (parts (insert X H))"
apply (rule equalityI)
apply (rule subsetI)
apply (erule parts.induct, auto)
apply (blast intro: parts.Body)
done

lemma parts_insert_MPair [simp]:
     "parts (insert {|X,Y|} H) =  
          insert {|X,Y|} (parts (insert X (insert Y H)))"
apply (rule equalityI)
apply (rule subsetI)
apply (erule parts.induct, auto)
apply (blast intro: parts.Fst parts.Snd)+
done

lemma parts_image_Key [simp]: "parts (Key`N) = Key`N"
apply auto
apply (erule parts.induct, auto)
done


text{*In any message, there is an upper bound N on its greatest nonce.*}
(*
lemma msg_Nonce_supply: "\<exists>N. \<forall>n. N\<le>n --> Nonce n \<notin> parts {msg}"
apply (induct msg)
apply (simp_all (no_asm_simp) add: exI parts_insert2)
 txt{*MPair case: blast works out the necessary sum itself!*}
 prefer 2 apply auto apply (blast elim!: add_leE)
txt{*Nonce case*}
apply (rule_tac x = "N + Suc nat" in exI, auto) 
done
*)


subsection{*Inductive relation "analz"*}

text{*Inductive definition of "analz" -- what can be broken down from a set of
    messages, including keys.  A form of downward closure.  Pairs can
    be taken apart; messages decrypted with known keys.  *}

inductive_set
  analz :: "msg set => msg set"
  for H :: "msg set"
  where
    Inj [intro,simp] :    "X \<in> H ==> X \<in> analz H"
  | Fst:     "{|X,Y|} \<in> analz H ==> X \<in> analz H"
  | Snd:     "{|X,Y|} \<in> analz H ==> Y \<in> analz H"
  | Decrypt [dest]: 
             "[|Crypt K X \<in> analz H; Key(invKey K): analz H|] ==> X \<in> analz H"


text{*Monotonicity; Lemma 1 of Lowe's paper*}
lemma analz_mono: "G\<subseteq>H ==> analz(G) \<subseteq> analz(H)"
apply auto
apply (erule analz.induct) 
apply (auto dest: analz.Fst analz.Snd) 
done

lemmas analz_monotonic = analz_mono [THEN [2] rev_subsetD]

text{*Making it safe speeds up proofs*}
lemma MPair_analz [elim!]:
     "[| {|X,Y|} \<in> analz H;        
             [| X \<in> analz H; Y \<in> analz H |] ==> P   
          |] ==> P"
by (blast dest: analz.Fst analz.Snd)

lemma analz_increasing: "H \<subseteq> analz(H)"
by blast

lemma analz_subset_parts: "analz H \<subseteq> parts H"
apply (rule subsetI)
apply (erule analz.induct, blast+)
done

lemmas analz_into_parts = analz_subset_parts [THEN subsetD]

lemmas not_parts_not_analz = analz_subset_parts [THEN contra_subsetD]


lemma parts_analz [simp]: "parts (analz H) = parts H"
apply (rule equalityI)
apply (rule analz_subset_parts [THEN parts_mono, THEN subset_trans], simp)
apply (blast intro: analz_increasing [THEN parts_mono, THEN subsetD])
done

lemma analz_parts [simp]: "analz (parts H) = parts H"
apply auto
apply (erule analz.induct, auto)
done

lemmas analz_insertI = subset_insertI [THEN analz_mono, THEN [2] rev_subsetD]

subsubsection{*General equational properties *}

lemma analz_empty [simp]: "analz{} = {}"
apply safe
apply (erule analz.induct, blast+)
done

text{*Converse fails: we can analz more from the union than from the 
  separate parts, as a key in one might decrypt a message in the other*}
lemma analz_Un: "analz(G) \<union> analz(H) \<subseteq> analz(G \<union> H)"
by (intro Un_least analz_mono Un_upper1 Un_upper2)

lemma analz_insert: "insert X (analz H) \<subseteq> analz(insert X H)"
by (blast intro: analz_mono [THEN [2] rev_subsetD])

subsubsection{*Rewrite rules for pulling out atomic messages *}

lemmas analz_insert_eq_I = equalityI [OF subsetI analz_insert]

lemma analz_insert_Agent [simp]:
     "analz (insert (Agent agt) H) = insert (Agent agt) (analz H)"
apply (rule analz_insert_eq_I) 
apply (erule analz.induct, auto) 
done

lemma analz_insert_Nonce [simp]:
     "analz (insert (Nonce N) H) = insert (Nonce N) (analz H)"
apply (rule analz_insert_eq_I) 
apply (erule analz.induct, auto) 
done

lemma analz_insert_Number [simp]:
     "analz (insert (Number N) H) = insert (Number N) (analz H)"
apply (rule analz_insert_eq_I) 
apply (erule analz.induct, auto) 
done

lemma analz_insert_Hash [simp]:
     "analz (insert (Hash X) H) = insert (Hash X) (analz H)"
apply (rule analz_insert_eq_I) 
apply (erule analz.induct, auto) 
done

text{*Can only pull out Keys if they are not needed to decrypt the rest*}
lemma analz_insert_Key [simp]: 
    "K \<notin> keysFor (analz H) ==>   
          analz (insert (Key K) H) = insert (Key K) (analz H)"
apply (unfold keysFor_def)
apply (rule analz_insert_eq_I) 
apply (erule analz.induct, auto) 
done

lemma analz_insert_MPair [simp]:
     "analz (insert {|X,Y|} H) =  
          insert {|X,Y|} (analz (insert X (insert Y H)))"
apply (rule equalityI)
apply (rule subsetI)
apply (erule analz.induct, auto)
apply (erule analz.induct)
apply (blast intro: analz.Fst analz.Snd)+
done

text{*Can pull out enCrypted message if the Key is not known*}
lemma analz_insert_Crypt:
     "Key (invKey K) \<notin> analz H 
      ==> analz (insert (Crypt K X) H) = insert (Crypt K X) (analz H)"
apply (rule analz_insert_eq_I) 
apply (erule analz.induct, auto) 

done

lemma lemma1: "Key (invKey K) \<in> analz H ==>   
               analz (insert (Crypt K X) H) \<subseteq>  
               insert (Crypt K X) (analz (insert X H))"
apply (rule subsetI)
apply (erule_tac x = x in analz.induct, auto)
done

lemma lemma2: "Key (invKey K) \<in> analz H ==>   
               insert (Crypt K X) (analz (insert X H)) \<subseteq>  
               analz (insert (Crypt K X) H)"
apply auto
apply (erule_tac x = x in analz.induct, auto)
apply (blast intro: analz_insertI analz.Decrypt)
done

lemma analz_insert_Decrypt:
     "Key (invKey K) \<in> analz H ==>   
               analz (insert (Crypt K X) H) =  
               insert (Crypt K X) (analz (insert X H))"
by (intro equalityI lemma1 lemma2)

text{*Case analysis: either the message is secure, or it is not! Effective,
but can cause subgoals to blow up! Use with @{text "split_if"}; apparently
@{text "split_tac"} does not cope with patterns such as @{term"analz (insert
(Crypt K X) H)"} *} 
lemma analz_Crypt_if [simp]:
     "analz (insert (Crypt K X) H) =                 
          (if (Key (invKey K) \<in> analz H)                 
           then insert (Crypt K X) (analz (insert X H))  
           else insert (Crypt K X) (analz H))"
by (simp add: analz_insert_Crypt analz_insert_Decrypt)


text{*This rule supposes "for the sake of argument" that we have the key.*}
lemma analz_insert_Crypt_subset:
     "analz (insert (Crypt K X) H) \<subseteq>   
           insert (Crypt K X) (analz (insert X H))"
apply (rule subsetI)
apply (erule analz.induct, auto)
done


lemma analz_image_Key [simp]: "analz (Key`N) = Key`N"
apply auto
apply (erule analz.induct, auto)
done


subsubsection{*Idempotence and transitivity *}

lemma analz_analzD [dest!]: "X\<in> analz (analz H) ==> X\<in> analz H"
by (erule analz.induct, blast+)

lemma analz_idem [simp]: "analz (analz H) = analz H"
by blast

lemma analz_subset_iff [simp]: "(analz G \<subseteq> analz H) = (G \<subseteq> analz H)"
apply (rule iffI)
apply (iprover intro: subset_trans analz_increasing)  
apply (frule analz_mono, simp) 
done

lemma analz_trans: "[| X\<in> analz G;  G \<subseteq> analz H |] ==> X\<in> analz H"
by (drule analz_mono, blast)

text{*Cut; Lemma 2 of Lowe*}
lemma analz_cut: "[| Y\<in> analz (insert X H);  X\<in> analz H |] ==> Y\<in> analz H"
by (erule analz_trans, blast)

(*Cut can be proved easily by induction on
   "Y: analz (insert X H) ==> X: analz H --> Y: analz H"
*)

text{*This rewrite rule helps in the simplification of messages that involve
  the forwarding of unknown components (X).  Without it, removing occurrences
  of X can be very complicated. *}
lemma analz_insert_eq: "X\<in> analz H ==> analz (insert X H) = analz H"
by (blast intro: analz_cut analz_insertI)


text{*A congruence rule for "analz" *}

lemma analz_subset_cong:
     "[| analz G \<subseteq> analz G'; analz H \<subseteq> analz H' |] 
      ==> analz (G \<union> H) \<subseteq> analz (G' \<union> H')"
apply simp
apply (iprover intro: conjI subset_trans analz_mono Un_upper1 Un_upper2) 
done

lemma analz_cong:
     "[| analz G = analz G'; analz H = analz H' |] 
      ==> analz (G \<union> H) = analz (G' \<union> H')"
by (intro equalityI analz_subset_cong, simp_all) 

lemma analz_insert_cong:
     "analz H = analz H' ==> analz(insert X H) = analz(insert X H')"
by (force simp only: insert_def intro!: analz_cong)

text{*If there are no pairs or encryptions then analz does nothing*}
lemma analz_trivial:
     "[| \<forall>X Y. {|X,Y|} \<notin> H;  \<forall>X K. Crypt K X \<notin> H |] ==> analz H = H"
apply safe
apply (erule analz.induct, blast+)
done

text{*These two are obsolete (with a single Spy) but cost little to prove...*}
lemma analz_UN_analz_lemma:
     "X\<in> analz (\<Union>i\<in>A. analz (H i)) ==> X\<in> analz (\<Union>i\<in>A. H i)"
apply (erule analz.induct)
apply (blast intro: analz_mono [THEN [2] rev_subsetD])+
done

lemma analz_UN_analz [simp]: "analz (\<Union>i\<in>A. analz (H i)) = analz (\<Union>i\<in>A. H i)"
by (blast intro: analz_UN_analz_lemma analz_mono [THEN [2] rev_subsetD])


subsection{*Inductive relation "synth"*}

text{*Inductive definition of "synth" -- what can be built up from a set of
    messages.  A form of upward closure.  Pairs can be built, messages
    encrypted with known keys.  Agent names are public domain.
    Numbers can be guessed, but Nonces cannot be.  *}

inductive_set
  synth :: "msg set => msg set"
  for H :: "msg set"
  where
    Inj    [intro]:   "X \<in> H ==> X \<in> synth H"
  | Agent  [intro]:   "Agent agt \<in> synth H"
  | Number [intro]:   "Number n  \<in> synth H"
  | Hash   [intro]:   "X \<in> synth H ==> Hash X \<in> synth H"
  | MPair  [intro]:   "[|X \<in> synth H;  Y \<in> synth H|] ==> {|X,Y|} \<in> synth H"
  | Crypt  [intro]:   "[|X \<in> synth H;  Key(K) \<in> H|] ==> Crypt K X \<in> synth H"

text{*Monotonicity*}
lemma synth_mono: "G\<subseteq>H ==> synth(G) \<subseteq> synth(H)"
  by (auto, erule synth.induct, auto)  

text{*NO @{text Agent_synth}, as any Agent name can be synthesized.  
  The same holds for @{term Number}*}
inductive_cases Nonce_synth [elim!]: "Nonce n \<in> synth H"
inductive_cases Key_synth   [elim!]: "Key K \<in> synth H"
inductive_cases Hash_synth  [elim!]: "Hash X \<in> synth H"
inductive_cases MPair_synth [elim!]: "{|X,Y|} \<in> synth H"
inductive_cases Crypt_synth [elim!]: "Crypt K X \<in> synth H"


lemma synth_increasing: "H \<subseteq> synth(H)"
by blast

subsubsection{*Unions *}

text{*Converse fails: we can synth more from the union than from the 
  separate parts, building a compound message using elements of each.*}
lemma synth_Un: "synth(G) \<union> synth(H) \<subseteq> synth(G \<union> H)"
by (intro Un_least synth_mono Un_upper1 Un_upper2)

lemma synth_insert: "insert X (synth H) \<subseteq> synth(insert X H)"
by (blast intro: synth_mono [THEN [2] rev_subsetD])

subsubsection{*Idempotence and transitivity *}

lemma synth_synthD [dest!]: "X\<in> synth (synth H) ==> X\<in> synth H"
by (erule synth.induct, blast+)

lemma synth_idem: "synth (synth H) = synth H"
by blast

lemma synth_subset_iff [simp]: "(synth G \<subseteq> synth H) = (G \<subseteq> synth H)"
apply (rule iffI)
apply (iprover intro: subset_trans synth_increasing)  
apply (frule synth_mono, simp add: synth_idem) 
done

lemma synth_trans: "[| X\<in> synth G;  G \<subseteq> synth H |] ==> X\<in> synth H"
by (drule synth_mono, blast)

text{*Cut; Lemma 2 of Lowe*}
lemma synth_cut: "[| Y\<in> synth (insert X H);  X\<in> synth H |] ==> Y\<in> synth H"
by (erule synth_trans, blast)

lemma Agent_synth [simp]: "Agent A \<in> synth H"
by blast

lemma Number_synth [simp]: "Number n \<in> synth H"
by blast

lemma Nonce_synth_eq [simp]: "(Nonce N \<in> synth H) = (Nonce N \<in> H)"
by blast

lemma Key_synth_eq [simp]: "(Key K \<in> synth H) = (Key K \<in> H)"
by blast

lemma Crypt_synth_eq [simp]:
     "Key K \<notin> H ==> (Crypt K X \<in> synth H) = (Crypt K X \<in> H)"
by blast


lemma keysFor_synth [simp]: 
    "keysFor (synth H) = keysFor H \<union> invKey`{K. Key K \<in> H}"
by (unfold keysFor_def, blast)


subsubsection{*Combinations of parts, analz and synth *}

lemma parts_synth [simp]: "parts (synth H) = parts H \<union> synth H"
apply (rule equalityI)
apply (rule subsetI)
apply (erule parts.induct)
apply (blast intro: synth_increasing [THEN parts_mono, THEN subsetD] 
                    parts.Fst parts.Snd parts.Body)+
done

lemma analz_analz_Un [simp]: "analz (analz G \<union> H) = analz (G \<union> H)"
apply (intro equalityI analz_subset_cong)+
apply simp_all
done

lemma analz_synth_Un [simp]: "analz (synth G \<union> H) = analz (G \<union> H) \<union> synth G"
apply (rule equalityI)
apply (rule subsetI)
apply (erule analz.induct)
prefer 5 apply (blast intro: analz_mono [THEN [2] rev_subsetD])
apply (blast intro: analz.Fst analz.Snd analz.Decrypt)+
done

lemma analz_synth [simp]: "analz (synth H) = analz H \<union> synth H"
apply (cut_tac H = "{}" in analz_synth_Un)
apply (simp (no_asm_use))
done

text {* chsp: added *}

lemma analz_Un_analz [simp]: "analz (G \<union> analz H) = analz (G \<union> H)"
by (subst Un_commute, auto)+

lemma analz_synth_Un2 [simp]: "analz (G \<union> synth H) = analz (G \<union> H) \<union> synth H"
by (subst Un_commute, auto)+


subsubsection{*For reasoning about the Fake rule in traces *}

lemma parts_insert_subset_Un: "X\<in> G ==> parts(insert X H) \<subseteq> parts G \<union> parts H"
by (rule subset_trans [OF parts_mono parts_Un_subset2], blast)

text{*More specifically for Fake.  Very occasionally we could do with a version
  of the form  @{term"parts{X} \<subseteq> synth (analz H) \<union> parts H"} *}
lemma Fake_parts_insert:
     "X \<in> synth (analz H) ==>  
      parts (insert X H) \<subseteq> synth (analz H) \<union> parts H"
apply (drule parts_insert_subset_Un)
apply (simp (no_asm_use))
apply blast
done

lemma Fake_parts_insert_in_Un:
     "[|Z \<in> parts (insert X H);  X \<in> synth (analz H)|] 
      ==> Z \<in>  synth (analz H) \<union> parts H"
by (blast dest: Fake_parts_insert  [THEN subsetD, dest])

text{*@{term H} is sometimes @{term"Key ` KK \<union> spies evs"}, so can't put 
  @{term "G=H"}.*}
lemma Fake_analz_insert:
     "X\<in> synth (analz G) ==>  
      analz (insert X H) \<subseteq> synth (analz G) \<union> analz (G \<union> H)"
apply (rule subsetI)
apply (subgoal_tac "x \<in> analz (synth (analz G) \<union> H) ")
prefer 2 
  apply (blast intro: analz_mono [THEN [2] rev_subsetD] 
                      analz_mono [THEN synth_mono, THEN [2] rev_subsetD])
apply (simp (no_asm_use))
apply blast
done

lemma analz_conj_parts [simp]:
     "(X \<in> analz H & X \<in> parts H) = (X \<in> analz H)"
by (blast intro: analz_subset_parts [THEN subsetD])

lemma analz_disj_parts [simp]:
     "(X \<in> analz H | X \<in> parts H) = (X \<in> parts H)"
by (blast intro: analz_subset_parts [THEN subsetD])

text{*Without this equation, other rules for synth and analz would yield
  redundant cases*}
lemma MPair_synth_analz [iff]:
     "({|X,Y|} \<in> synth (analz H)) =  
      (X \<in> synth (analz H) & Y \<in> synth (analz H))"
by blast

lemma Crypt_synth_analz:
     "[| Key K \<in> analz H;  Key (invKey K) \<in> analz H |]  
       ==> (Crypt K X \<in> synth (analz H)) = (X \<in> synth (analz H))"
by blast


lemma Hash_synth_analz [simp]:
     "X \<notin> synth (analz H)  
      ==> (Hash{|X,Y|} \<in> synth (analz H)) = (Hash{|X,Y|} \<in> analz H)"
by blast


subsection{*HPair: a combination of Hash and MPair*}

subsubsection{*Freeness *}

lemma Agent_neq_HPair: "Agent A ~= Hash[X] Y"
by (unfold HPair_def, simp)

lemma Nonce_neq_HPair: "Nonce N ~= Hash[X] Y"
by (unfold HPair_def, simp)

lemma Number_neq_HPair: "Number N ~= Hash[X] Y"
by (unfold HPair_def, simp)

lemma Key_neq_HPair: "Key K ~= Hash[X] Y"
by (unfold HPair_def, simp)

lemma Hash_neq_HPair: "Hash Z ~= Hash[X] Y"
by (unfold HPair_def, simp)

lemma Crypt_neq_HPair: "Crypt K X' ~= Hash[X] Y"
by (unfold HPair_def, simp)

lemmas HPair_neqs = Agent_neq_HPair Nonce_neq_HPair Number_neq_HPair 
                    Key_neq_HPair Hash_neq_HPair Crypt_neq_HPair

declare HPair_neqs [iff]
declare HPair_neqs [symmetric, iff]

lemma HPair_eq [iff]: "(Hash[X'] Y' = Hash[X] Y) = (X' = X & Y'=Y)"
by (simp add: HPair_def)

lemma MPair_eq_HPair [iff]:
     "({|X',Y'|} = Hash[X] Y) = (X' = Hash{|X,Y|} & Y'=Y)"
by (simp add: HPair_def)

lemma HPair_eq_MPair [iff]:
     "(Hash[X] Y = {|X',Y'|}) = (X' = Hash{|X,Y|} & Y'=Y)"
by (auto simp add: HPair_def)


subsubsection{*Specialized laws, proved in terms of those for Hash and MPair *}

lemma keysFor_insert_HPair [simp]: "keysFor (insert (Hash[X] Y) H) = keysFor H"
by (simp add: HPair_def)

lemma parts_insert_HPair [simp]: 
    "parts (insert (Hash[X] Y) H) =  
     insert (Hash[X] Y) (insert (Hash{|X,Y|}) (parts (insert Y H)))"
by (simp add: HPair_def)

lemma analz_insert_HPair [simp]: 
    "analz (insert (Hash[X] Y) H) =  
     insert (Hash[X] Y) (insert (Hash{|X,Y|}) (analz (insert Y H)))"
by (simp add: HPair_def)

lemma HPair_synth_analz [simp]:
     "X \<notin> synth (analz H)  
    ==> (Hash[X] Y \<in> synth (analz H)) =  
        (Hash {|X, Y|} \<in> analz H & Y \<in> synth (analz H))"
by (simp add: HPair_def)


text{*We do NOT want Crypt... messages broken up in protocols!!*}
declare parts.Body [rule del]


text{*Rewrites to push in Key and Crypt messages, so that other messages can
    be pulled out using the @{text analz_insert} rules*}

lemmas pushKeys =
  insert_commute [of "Key K" "Agent C" for K C]
  insert_commute [of "Key K" "Nonce N" for K N]
  insert_commute [of "Key K" "Number N" for K N]
  insert_commute [of "Key K" "Hash X" for K X]
  insert_commute [of "Key K" "MPair X Y" for K X Y]
  insert_commute [of "Key K" "Crypt X K'" for K K' X]

lemmas pushCrypts =
  insert_commute [of "Crypt X K" "Agent C" for X K C]
  insert_commute [of "Crypt X K" "Agent C" for X K C]
  insert_commute [of "Crypt X K" "Nonce N" for X K N]
  insert_commute [of "Crypt X K" "Number N"  for X K N]
  insert_commute [of "Crypt X K" "Hash X'"  for X K X']
  insert_commute [of "Crypt X K" "MPair X' Y"  for X K X' Y]

text{*Cannot be added with @{text "[simp]"} -- messages should not always be
  re-ordered. *}
lemmas pushes = pushKeys pushCrypts


text{*By default only @{text o_apply} is built-in.  But in the presence of
eta-expansion this means that some terms displayed as @{term "f o g"} will be
rewritten, and others will not!*}
declare o_def [simp]


lemma Crypt_notin_image_Key [simp]: "Crypt K X \<notin> Key ` A"
by auto

lemma Hash_notin_image_Key [simp] :"Hash X \<notin> Key ` A"
by auto

lemma synth_analz_mono: "G\<subseteq>H ==> synth (analz(G)) \<subseteq> synth (analz(H))"
by (iprover intro: synth_mono analz_mono) 

lemma Fake_analz_eq [simp]:
     "X \<in> synth(analz H) ==> synth (analz (insert X H)) = synth (analz H)"
apply (drule Fake_analz_insert[of _ _ "H"])
apply (simp add: synth_increasing[THEN Un_absorb2])
apply (drule synth_mono)
apply (simp add: synth_idem)
apply (rule equalityI)
apply (simp add: )
apply (rule synth_analz_mono, blast)   
done

text{*Two generalizations of @{text analz_insert_eq}*}
lemma gen_analz_insert_eq [rule_format]:
     "X \<in> analz H ==> ALL G. H \<subseteq> G --> analz (insert X G) = analz G"
by (blast intro: analz_cut analz_insertI analz_mono [THEN [2] rev_subsetD])

lemma synth_analz_insert_eq [rule_format]:
     "X \<in> synth (analz H) 
      ==> ALL G. H \<subseteq> G --> (Key K \<in> analz (insert X G)) = (Key K \<in> analz G)"
apply (erule synth.induct) 
apply (simp_all add: gen_analz_insert_eq subset_trans [OF _ subset_insertI]) 
done

lemma Fake_parts_sing:
     "X \<in> synth (analz H) ==> parts{X} \<subseteq> synth (analz H) \<union> parts H"
apply (rule subset_trans) 
 apply (erule_tac [2] Fake_parts_insert)
apply (rule parts_mono, blast)
done

lemmas Fake_parts_sing_imp_Un = Fake_parts_sing [THEN [2] rev_subsetD]


text{*For some reason, moving this up can make some proofs loop!*}
declare invKey_K [simp]


end
