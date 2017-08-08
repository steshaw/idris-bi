import Bip

import Language.Reflection
-- for Elab and Utils
import Pruviloj.Core
import Pruviloj.Induction

%default total
%language ElabReflection

-- Following PArith/BinPos.v

-- xI_succ_xO

iSuccO : (p: Bip) -> (I p) = bipSucc (O p)
iSuccO _ = Refl

iSuccO' : (p: Bip) -> (I p) = bipSucc (O p)
iSuccO' = %runElab
  (do intro'
      reflexivity)

-- succ_discr

Uninhabited (U = O n) where
  uninhabited Refl impossible

Uninhabited (U = I n) where
  uninhabited Refl impossible

Uninhabited (I n = O m) where
  uninhabited Refl impossible

covering
absurdity : Elab ()
absurdity =
  do p <- gensym "p"
     intro p
     [a, b, c, d] <- apply (Var `{absurd}) [True, True, False, False]
       | _ => fail [TextPart "Wrong number of holes in absurdity"]
     solve
     focus d
     fill (Var p)
     solve
     resolveTC `{absurd}

-- Example lemma:
-- succSimple : Not (U = O U)
-- succSimple = %runElab (do absurdity)

succDiscr : (p: Bip) -> Not (p = bipSucc p)
succDiscr U prf = absurd prf
succDiscr (O a) prf = absurd prf
succDiscr (I a) prf = absurd prf

aintro' : Elab ()
aintro' = do attack
             intro'

aabsurdity : Elab ()
aabsurdity = do attack
                absurdity

-- Same as : (p: Bip) -> p = bipSucc p -> Void
succDiscr' : (p: Bip) -> Not (p = bipSucc p)
succDiscr' = %runElab
  (do arg <- gensym "arg"
      intro arg
      induction (Var arg)
      aabsurdity
      solve
      aintro'
      aintro'
      absurdity
      solve
      solve
      aintro'
      aintro'
      aabsurdity
      solve
      solve
      solve)

-- pred_double_spec

predDoubleSpec : (p: Bip) -> bipDMO p = bipPred (O p)
predDoubleSpec _ = Refl

predDoubleSpec' : (p: Bip) -> bipDMO p = bipPred (O p)
predDoubleSpec' = %runElab
  (do intro'
      reflexivity)

-- succ_pred_double

succPredDouble : (p: Bip) -> bipSucc (bipDMO p) = (O p)
succPredDouble U = Refl
succPredDouble (O a) = rewrite succPredDouble a in Refl
succPredDouble (I a) = Refl

-- NOTE: Elab proofs from here on are clunky
-- They were created using :elab in the REPL
-- TODO: Tidy these proofs, e.g. removing compute

succPredDouble' : (p: Bip) -> bipSucc (bipDMO p) = (O p)
succPredDouble' = %runElab
  (do arg <- gensym "arg"
      intro arg
      induction (Var arg)
      compute
      reflexivity
      compute
      attack
      n <- intro'
      intro (UN "ih")
      rewriteWith (Var `{{ih}})
      reflexivity
      solve
      aintro'
      aintro'
      compute
      reflexivity
      solve
      compute
      solve)

-- pred_double_succ

predDoubleSucc : (p: Bip) -> bipDMO (bipSucc p) = (I p)
predDoubleSucc U = Refl
predDoubleSucc (O a) = Refl
predDoubleSucc (I a) = rewrite predDoubleSucc a in Refl

predDoubleSucc' : (p: Bip) -> bipDMO (bipSucc p) = (I p)
predDoubleSucc' = %runElab
  (do intro (UN "arg")
      induction (Var `{{arg}})
      compute
      reflexivity
      compute
      aintro'
      aintro'
      reflexivity
      solve
      compute
      solve
      compute
      aintro'
      intro (UN "ih")
      rewriteWith (Var `{{ih}})
      reflexivity
      solve)

-- double_succ

doubleSucc : (p: Bip) -> (O (bipSucc p)) = (bipSucc (bipSucc (O p)))
doubleSucc _ = Refl

doubleSucc' : (p: Bip) -> (O (bipSucc p)) = (bipSucc (bipSucc (O p)))
doubleSucc' = %runElab
  (do intro'
      reflexivity)

-- pred_double_x0_discr

predDoubleODiscr : (p: Bip) -> Not ((bipDMO p) = (O p))
predDoubleODiscr U = absurd
predDoubleODiscr (O a) = absurd
predDoubleODiscr (I a) = absurd

predDoubleODiscr' : (p: Bip) -> Not ((bipDMO p) = (O p))
predDoubleODiscr' = %runElab
  (do intro (UN "arg")
      induction (Var `{{arg}})
      compute
      aabsurdity
      solve
      compute
      aintro'
      aintro'
      aabsurdity
      solve
      solve
      solve
      compute
      aintro'
      aintro'
      aabsurdity
      solve
      solve
      solve)

-- succ_not_1

succNotU : (p: Bip) -> Not ((bipSucc p) = U)
succNotU U = absurd
succNotU (O _) = absurd
succNotU (I _) = absurd

succNotU' : (p: Bip) -> Not ((bipSucc p) = U)
succNotU' = %runElab
  (do intro (UN "arg")
      induction (Var `{{arg}})
      aabsurdity
      solve
      aintro'
      aintro'
      aabsurdity
      solve
      solve
      solve
      aintro'
      aintro'
      aabsurdity
      solve
      solve
      solve)

-- pred_succ

partial
inductarg : Elab ()
inductarg =
  do intro (UN "arg")
     induction (Var `{{arg}})
     compute

rewritearg : Elab ()
rewritearg =
  do intro (UN "ih")
     rewriteWith (Var `{{ih}})

predSucc : (p: Bip) -> bipPred (bipSucc p) = p
predSucc U = Refl
predSucc (O a) = Refl
predSucc (I a) = case a of
  U => Refl
  (O b) => Refl
  (I b) => rewrite predSucc (I b) in Refl

predSucc' : (p: Bip) -> bipPred (bipSucc p) = p
predSucc' = %runElab
  (do inductarg
      reflexivity
      compute
      aintro'
      aintro'
      reflexivity
      solve
      solve
      compute
      aintro'
      aintro'
      a <- apply (Var `{predDoubleSucc}) [True]
      solve
      solve
      solve)

-- succ_pred_or

succPredOr : (p: Bip) -> Either (p = U) ((bipSucc (bipPred p)) = p)
succPredOr U = Left Refl
succPredOr (O a) = case a of
  U => Right Refl
  (O b) =>
    -- Either (O (O b) = U) (O (bipSucc (bipDMO b)) = O (O b))
    -- Cf. succPredDouble : (p: Bip) -> bipSucc (bipDMO p) = (O p)
    rewrite succPredDouble (O b) in
    Right Refl
  (I b) => Right Refl
succPredOr (I a) = Right Refl

succPredOr' : (p: Bip) -> Either (p = U) ((bipSucc (bipPred p)) = p)
succPredOr' = ?a

zzOrZsz : Either (Z = Z) (Z = S Z)
zzOrZsz = ?b
