import Mathlib.Dynamics.Ergodic.Action.Regular
import Mathlib.MeasureTheory.Measure.Haar.OfBasis
import Mathlib.MeasureTheory.Measure.RegularityCompacts
import Mathlib.Order.CompletePartialOrder
import Mathlib.Topology.EMetricSpace.Paracompact
import Mathlib.Topology.Separation.CompletelyRegular
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.InnerProductSpace.PiL2
-- #min_imports

-- LeanSearch
import LeanSearchClient
-- #leansearch "Union of two compact sets is also compact?"

#check MeasurableSet.exists_isCompact_diff_lt
-- Want to apply the lemma above to [0, 1] in R
#check Set.Ioo 0 1
#check MeasurableSet.exists_isCompact_diff_lt (measurableSet_Ioo : MeasurableSet (Set.Ioo 0 1))

variable (A B : Set ℝ) (hA : MeasurableSet A) (hB : MeasurableSet B)
#check MeasurableSet.exists_isCompact_diff_lt hA

-- μ(A \ Aε) = μ(A) - μ(Aε)

#check MeasureTheory.measure_diff

-- When α = ℝ,
-- (∀ (ε : α), 0 < ε → a < b + ε) → a ≤ b

#check le_of_forall_pos_lt_add

variable (a b : ℝ) (he : ∀ (ε : ℝ), 0 < ε → a < b + ε)
#check le_of_forall_pos_lt_add

-- translation invariance of measure --

open Set Pointwise Filter MeasureTheory MeasureTheory.Measure TopologicalSpace

theorem measure_translation_of_set (s : Set ℝ) (c : ℝ) : volume (image (fun x ↦ x + c) s) = volume s := by
  simp only [image_add_right, measure_preimage_add_right]

#check measure_translation_of_set
#check measure_union_add_inter
#check MeasureTheory.measure_mono
#check IsCompact.sSup_mem
#check IsCompact.sInf_mem
#check singleton_subset_iff
#check add_subset_add_right

-- It's a shame
example (A B : Set ℝ) : A + B = B + A := by
  exact Set.addCommMonoid.proof_1 A B

lemma volume_le_volume_add_right
    {A B : Set ℝ} (hB : B.Nonempty)
    : volume A ≤ volume (A + B) := by
  obtain ⟨b, hb⟩ := hB -- hB is a pair of b and proof of b in B
  calc
    volume A = volume (A + {b}) := by
      rw [add_singleton, image_add_right,
      measure_preimage_add_right]
    _ ≤ volume (A + B) := by
      apply measure_mono
      apply add_subset_add_left
      rw [singleton_subset_iff]
      exact hb

lemma volume_le_volume_add_left
    {A B : Set ℝ} (hB : B.Nonempty)
    : volume A ≤ volume (B + A) := by
  rw [addCommMonoid.proof_1 B]
  exact volume_le_volume_add_right hB

-- Maybe (or maybe not) factor out the lemmas below
/-
have hhh : volume A ≤ volume C := by
  calc
    volume A ≤ volume (A + B) := volume_le_volume_add_right hB
    _ ≤ volume C := by
      apply measure_mono
      exact h
have hhh' : volume B ≤ volume C := by
  calc
    volume B ≤ volume (A + B) := volume_le_volume_add_left hA
    _ ≤ volume C := by
      apply measure_mono
      exact h
-/

#check MeasurableSet.exists_isCompact_diff_lt

-- important TODO: complete this
lemma MeasurableSet.exists_isCompact_Nonempty_diff_lt
    {α : Type} [MeasurableSpace α] {μ : Measure α} [TopologicalSpace α]
    [OpensMeasurableSpace α] [T2Space α] [μ.InnerRegularCompactLTTop]
    {A : Set α} (hA : A.Nonempty) (mA : MeasurableSet A) (h'A : μ A ≠ ⊤)
    {ε : ENNReal} (hε : ε ≠ 0) : ∃ K ⊆ A, K.Nonempty ∧ IsCompact K ∧ μ (A \ K) < ε := by
  sorry

lemma one_dim_BMInequality (A B C : Set ℝ)
    -- TODO: remove the line below
    -- [TopologicalSpace ℝ] [OpensMeasurableSpace ℝ] [T2Space ℝ]
    (hA : A.Nonempty) (hB : B.Nonempty) (hC : C.Nonempty)
    (mA : MeasurableSet A) (mB : MeasurableSet B) (mC : MeasurableSet C)
    (h : A + B ⊆ C)
    : volume A + volume B ≤ volume C := by
    --
  by_cases finA : volume A = ⊤
  · -- A is infinite
    rw [finA, _root_.top_add, ← finA]
    apply le_trans
      (volume_le_volume_add_right hB)
      (measure_mono h)
  -- Now assume A is finite
  by_cases finB : volume B = ⊤
  · -- B is infinite
    rw [finB, _root_.add_top, ← finB]
    apply le_trans
      (volume_le_volume_add_left hA)
      (measure_mono h)
  -- Now assume B is finite
  wlog cAB : IsCompact A ∧ IsCompact B with goal_cpt
  · -- Prove non-cpt A, B case assuming cpt A, B case
    apply le_of_forall_pos_le_add
    intros ε hε
    have hε' : ε ≠ 0 := by
      by_contra h
      rw [h] at hε
      rw [lt_self_iff_false] at hε
      exact hε
    -- TODO: replace the followings with MeasurableSet.exists_isCompact_Nonempty_diff_lt
    obtain ⟨Aε, inclusion_cptA, h_cptA, diff_cptA⟩ :=
      mA.exists_isCompact_diff_lt finA hε'
    obtain ⟨Bε, inclusion_cptB, h_cptB, diff_cptB⟩ :=
      mB.exists_isCompact_diff_lt finB hε'
    have inclusion_cpt : Aε + Bε ⊆ C := by
      have feather : Aε + Bε ⊆ A + B := by
        intros x hx
        have hx' : ∃ a ∈ Aε, ∃ b ∈ Bε, a + b = x := by
          exact mem_add.mpr hx
        obtain ⟨a, ha, b, hb, hx'⟩ := hx'
        have ha : a ∈ A := by
          -- found by `aesop?`
          subst hx'
          simp_all only [and_imp, not_and, ne_eq]
          exact inclusion_cptA ha
        have hb : b ∈ B := by
          -- found by `aesop?`
          subst hx'
          simp_all only [and_imp, not_and, ne_eq]
          exact inclusion_cptB hb
        have h : a + b ∈ A + B := by apply add_mem_add ha hb
        rw [← hx']
        exact h
      calc Aε + Bε ⊆ A + B := by apply feather
      _ ⊆ C := by apply h
    sorry

  -- Prove the theorem assuming cpt A, B
  obtain ⟨cA, cB⟩ := cAB
  set At := sInf B +ᵥ A with eq_At
  set Bt := sSup A +ᵥ B with eq_Bt
  have eq_At_vol : volume At = volume A := by
    rw [eq_At]
    simp only [measure_vadd]
  have eq_Bt_vol : volume Bt = volume B := by
    rw [eq_Bt]
    simp only [measure_vadd]
  have sub_At : At ⊆ C := by
    rw [eq_At]
    apply Subset.trans _ h
    rw [add_comm]
    rw [← Set.singleton_vadd]
    apply Set.add_subset_add_right
    simp only [singleton_subset_iff]
    exact cB.sInf_mem hB
  have sub_Bt : Bt ⊆ C := by
    rw [eq_Bt]
    apply Subset.trans _ h
    rw [← Set.singleton_vadd]
    apply Set.add_subset_add_right
    simp only [singleton_subset_iff]
    exact cA.sSup_mem hA
  have cup_At_Bt : At ∪ Bt ⊆ C := by
    simp only [union_subset_iff]
    constructor
    · exact sub_At
    · exact sub_Bt
  have cap_At_Bt : At ∩ Bt = {sSup A + sInf B} := by
    sorry
  sorry
