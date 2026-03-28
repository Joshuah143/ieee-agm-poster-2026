#import "@preview/fletcher:0.5.7" as fletcher: diagram, node, edge, shapes

#let inference-diagram() = {
  // ─── Color Palette (matching sys_arch template) ───
  let c-bg = rgb("#f8fafc")
  let c-border = rgb("#e2e8f0")
  let c-input = rgb("#dbeafe")
  let c-input-stroke = rgb("#93c5fd")
  let c-core = rgb("#1e293b")
  let c-core-text = white
  let c-container = rgb("#f1f5f9")
  let c-container-stroke = rgb("#cbd5e1")
  let c-hw = white
  let c-hw-stroke = rgb("#94a3b8")
  let c-fb = rgb("#fef3c7")
  let c-fb-stroke = rgb("#d97706")
  let c-arrow = rgb("#475569")
  let c-text = rgb("#0f172a")
  let c-storage-fill = rgb("#f0fdf4")
  let c-storage-stroke = rgb("#86efac")
  let c-loop = rgb("#e11d48")

  set text(size: 8pt, fill: c-text)
  let edge = edge.with(label-angle: auto)

  // ─── Compact Node Presets ───
  let sensor = (
    shape: shapes.rect, fill: c-input, stroke: c-input-stroke + 1pt,
    corner-radius: 6pt, inset: 6pt,
  )
  let step-node = (
    shape: shapes.rect, fill: white, stroke: c-hw-stroke + 1pt,
    corner-radius: 6pt, inset: 6pt, width: 2.3cm,
  )
  let core = (
    shape: shapes.rect, fill: c-core, stroke: none,
    corner-radius: 5pt, inset: 6pt, width: 2.3cm,
  )
  let hw = (
    shape: shapes.rect, fill: c-hw, stroke: c-hw-stroke + 1.2pt,
    corner-radius: 8pt, inset: 6pt,
  )
  let storage = (
    shape: shapes.rect, fill: c-storage-fill, stroke: c-storage-stroke + 1pt,
    corner-radius: 6pt, inset: 6pt,
  )

  let lbl(t) = text(size: 6pt, fill: rgb("#64748b"), t)

  diagram(
    spacing: (0.7cm, 0.5cm),
    node-stroke: none,
    edge-stroke: 1.5pt + c-arrow,

    // ═══════════════════════════════════
    //  TITLE
    // ═══════════════════════════════════
    node((3, -2.9), text(size: 14pt, weight: "bold")[ACT Policy Inference Loop],
      fill: none, stroke: none),
    node((3, -2.5), text(size: 9pt, fill: rgb("#64748b"))[Bimanual SO101 Robot · 30 fps],
      fill: none, stroke: none),

    // ═══════════════════════════════════
    //  HARDWARE INPUTS (above Step 1)
    // ═══════════════════════════════════
    node((0.5, -1.3), align(center)[
      *3 RGB Cameras* \
      #text(size: 6.5pt, fill: rgb("#64748b"))[top · left · right] \
      #text(size: 6pt, fill: rgb("#64748b"))[640×480 · USB]
    ], ..sensor, name: <cameras>),

    node((-0.5, -1.3), align(center)[
      *2 Follower Arms* \
      #text(size: 6.5pt, fill: rgb("#64748b"))[left + right SO101] \
      #text(size: 6pt, fill: rgb("#64748b"))[12 joints · USB serial]
    ], ..sensor, name: <arms>),

    // ═══════════════════════════════════
    //  MAIN PIPELINE (row 0, left to right)
    // ═══════════════════════════════════

    // Step 1
    node((0, 0), align(center)[
      #text(size: 7.5pt, weight: "bold")[1. Observe]
      #text(size: 6.5pt)[get\_observation()] \
      #text(size: 6pt, fill: rgb("#64748b"))[12 floats + 3 images]
    ], ..step-node, name: <obs>),

    // Step 2
    node((1, 0), align(center)[
      #text(size: 7.5pt, weight: "bold")[2. Process]
      #text(size: 6.5pt)[obs\_processor] \
      #text(size: 6pt, fill: rgb("#64748b"))[normalize joints]
    ], ..step-node, name: <proc>),

    // Step 3
    node((2, 0), align(center)[
      #text(size: 7.5pt, weight: "bold")[3. Frame]
      #text(size: 6.5pt)[build\_dataset\_frame] \
      #text(size: 6pt, fill: rgb("#64748b"))[observation.\* schema]
    ], ..step-node, name: <frame>),

    // ── Step 4 — Policy Inference (vertical sub-pipeline) ──
    node((3, -1.5), text(size: 7.5pt, weight: "bold", fill: rgb("#64748b"))[
      Step 4 — Policy Inference \
      #h(0.1cm)
      #text(size: 6.5pt, weight: "regular")[predict\_action]
    ], fill: none, stroke: none, name: <s4-label>),

    node((3, -0.7), text(fill: c-core-text, size: 7.5pt)[
      *Preprocessor* \
      #text(size: 6.5pt)[normalize (μ/σ)]
    ], ..core, name: <preproc>),

    node((3, 0), text(fill: c-core-text, size: 7.5pt)[
      *ACT Policy* \
      #text(size: 6.5pt)[Transformer] \
      #text(size: 6pt)[→ 100 actions · GPU]
    ], ..core, name: <act>),

    node((3, 0.7), text(fill: c-core-text, size: 7.5pt)[
      *Postprocessor* \
      #text(size: 6.5pt)[denormalize]
    ], ..core, name: <postproc>),

    // Step 4 enclosure
    node(
      enclose: (<s4-label>, <preproc>, <act>, <postproc>),
      hide[.],
      fill: c-container, stroke: c-container-stroke + 1.5pt,
      corner-radius: 8pt, inset: 8pt,
      name: <policy-group>,
    ),

    // Step 5
    node((4, 0), align(center)[
      #text(size: 7.5pt, weight: "bold")[5. Convert]
      #text(size: 6.5pt)[make\_robot\_action] \
      #text(size: 6pt, fill: rgb("#64748b"))[→ action dict]
    ], ..step-node, name: <convert>),

    // Step 6
    node((5, 0), align(center)[
      #text(size: 7.5pt, weight: "bold")[6. Send]
      #text(size: 6.5pt)[send\_action()] \
      #text(size: 6pt, fill: rgb("#64748b"))[→ USB serial]
    ], ..step-node, name: <send>),

    // Step 7
    node((6, 0), align(center)[
      #text(size: 7.5pt, weight: "bold")[7. Timing]
      #text(size: 6.5pt)[precise\_sleep] \
      #text(size: 6pt, fill: rgb("#64748b"))[maintain 30 fps]
    ], shape: shapes.rect, fill: rgb("#fef9c3"), stroke: rgb("#eab308") + 1pt,
      corner-radius: 6pt, inset: 6pt, width: 2.3cm, name: <timing>),

    // ═══════════════════════════════════
    //  SIDE BRANCHES
    // ═══════════════════════════════════

    // Temporal Ensembling (above-right of Step 4)
    node((3.7, -1.2), align(center)[
      #text(size: 7pt, weight: "bold")[Temporal Ensembling] \
      #text(size: 6pt, fill: rgb("#64748b"))[coeff 0.01 · exp blend] \
      #text(size: 6pt, fill: rgb("#64748b"))[n\_action\_steps = 1]
    ], shape: shapes.rect, fill: c-fb,
      stroke: (dash: "dashed", paint: c-fb-stroke, thickness: 1pt),
      corner-radius: 6pt, inset: 6pt, name: <ensemble>),

    // Rerun Visualization (above Step 5)
    node((4.5, -1.2), align(center)[
      #text(size: 7pt, weight: "bold")[Rerun Visualization] \
      #text(size: 6pt, fill: rgb("#64748b"))[2× URDF arms · 3× cameras] \
      #text(size: 6pt, fill: rgb("#64748b"))[separate viewer window]
    ], ..storage, name: <rerun>),

    // Follower Arms Output (below Step 6)
    node((5, 1), align(center)[
      #text(size: 7pt, weight: "bold")[Follower Arms] \
      #text(size: 6pt, fill: rgb("#64748b"))[target positions] \
      #text(size: 6pt, fill: rgb("#64748b"))[USB serial → SO101]
    ], ..hw, name: <arms-out>),

    // ═══════════════════════════════════
    //  LOOP-BACK HIDDEN CORNERS
    // ═══════════════════════════════════
    node((6, 1.7), hide[.], stroke: none, fill: none, inset: 0pt, name: <loop-br>),
    node((0, 1.7), hide[.], stroke: none, fill: none, inset: 0pt, name: <loop-bl>),

    // ═══════════════════════════════════
    //  SECTION ENCLOSURE (light background)
    // ═══════════════════════════════════
    node(
      enclose: (<cameras>, <arms>, <obs>, <proc>, <frame>, <policy-group>, <ensemble>,
                <convert>, <send>, <timing>, <rerun>, <arms-out>,
                <loop-br>, <loop-bl>),
      hide[.], fill: c-bg, stroke: c-border + 1.5pt,
      corner-radius: 14pt, inset: 4pt, layer: -2,
    ),

    // ═══════════════════════════════════
    //  EDGES
    // ═══════════════════════════════════

    // Hardware → Step 1
    edge(<cameras>, <obs>, "-|>"),
    edge(<arms>, <obs>, "-|>"),

    // Main pipeline flow (left to right)
    edge(<obs>, <proc>, "-|>"),
    edge(<proc>, <frame>, "-|>"),

    // Into Step 4 (vertical: frame → preproc, down through, postproc → convert)
    edge(<frame>, <policy-group>, "-|>"),
    // edge(<preproc>, <act>, "-|>"),
    // edge(<act>, <postproc>, "-|>"),
    edge(<policy-group>, <convert>, "-|>"),

    // Continue pipeline
    edge(<convert>, <send>, "-|>"),
    edge(<send>, <timing>, "-|>"),

    // Temporal ensembling → policy group
    edge(<ensemble>, <convert>, "-|>",
      stroke: (dash: "dashed", paint: c-fb-stroke, thickness: 1.2pt)),

    // Rerun visualization side-branch (from Step 5)
    edge(<convert>, <rerun>, "-|>",
      stroke: (dash: "dashed", paint: c-storage-stroke, thickness: 1.2pt),),

    // Step 6 → follower arms output
    edge(<send>, <arms-out>, "-|>"),

    // ── 30 fps loop-back (below) ──
    edge(<timing>, <loop-br>, "-", stroke: 2pt + c-loop),
    edge(<loop-br>, <loop-bl>, "-", stroke: 2pt + c-loop,
      label: text(size: 7.5pt, fill: c-loop, weight: "bold")[30 fps loop]),
    edge(<loop-bl>, <obs>, "-|>", stroke: 2pt + c-loop),
  )
}
