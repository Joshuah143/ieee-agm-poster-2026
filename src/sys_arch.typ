#import "@preview/fletcher:0.5.7" as fletcher: diagram, node, edge, shapes

#let sys-arch-diagram() = {
  // --- Color Palette ---
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
  let c-disabled-fill = rgb("#f1f5f9")
  let c-disabled-stroke = rgb("#94a3b8")
  let c-disabled-text = rgb("#94a3b8")
  let c-storage-fill = rgb("#f0fdf4")
  let c-storage-stroke = rgb("#86efac")

  set text(size: 10pt, fill: c-text)
  let edge = edge.with(label-angle: auto)

  // --- Node Presets ---
  let sensor = (
    shape: shapes.rect, fill: c-input, stroke: c-input-stroke + 1pt,
    corner-radius: 8pt, inset: auto, width: 3.2cm,
  )
  let core = (
    shape: shapes.rect, fill: c-core, stroke: none,
    corner-radius: 6pt, inset: auto, width: 3.8cm,
  )
  let hw = (
    shape: shapes.rect, fill: c-hw, stroke: c-hw-stroke + 1.2pt,
    corner-radius: 12pt, inset: auto,
  )
  let output = (
    shape: shapes.rect, fill: white, stroke: c-hw-stroke + 1pt,
    corner-radius: 8pt, inset: auto,
  )
  let disabled = (
    shape: shapes.rect, fill: c-disabled-fill,
    stroke: (dash: "dashed", paint: c-disabled-stroke, thickness: 1pt),
    corner-radius: 8pt, inset: auto, width: 3.2cm,
  )
  let storage = (
    shape: shapes.rect, fill: c-storage-fill, stroke: c-storage-stroke + 1pt,
    corner-radius: 8pt, inset: auto,
  )

  // Edge label helper
  let lbl(t) = text(size: 7pt, fill: rgb("#64748b"), t)
  let disabled-edge = (dash: "dashed", paint: c-disabled-stroke, thickness: 1.5pt)

  diagram(
    spacing: (1.2cm, 0.7cm),
    node-stroke: none,
    edge-stroke: 1.5pt + c-arrow,

    // ══════════════════════════════════
    //  INFERENCE
    // ══════════════════════════════════

    // Inputs
    node((0, 0), [Cameras (3)], ..sensor, name: <i-cam>),
    node((0, 1), [Pose (12 joints)], ..sensor, name: <i-pose>),
    node((0, 0.5), text(fill: c-disabled-text)[Force Feedback], ..disabled, name: <i-ff>),

    // Control PC
    node((1, 0.5), text(size: 9pt, fill: rgb("#64748b"))[Control PC],
      fill: none, stroke: none),
    node((1, 0), text(fill: c-core-text)[Feature Extraction], ..core, name: <feat>),
    node((1, 1), text(fill: c-core-text)[IL Policy], ..core, name: <il>),
    node(
      enclose: (<feat>, <il>),
      hide[.],
      fill: c-container, stroke: c-container-stroke + 1pt,
      corner-radius: 10pt, inset: auto,
      name: <pc-inference>
    ),

    // Bridges
    node((2, 1), align(center, text(size: 9pt)[USB/UART \ Bridges]), ..hw, name: <i-usb2>),

    node((2, 0), [ReRun Visualizer], ..storage, name: <dataset-rv-inf>),

    // Outputs (boxed)
    node((3, 1), [Follower Pose], ..output, name: <i-la>),

    // Section enclosure
    node(
      enclose: (<i-cam>, <i-pose>, <i-ff>, <i-la>),
      hide[.], fill: c-bg, stroke: c-border + 1.5pt,
      corner-radius: 14pt, inset: 11pt, layer: -2,
    ),
    node((1.5, -1), text(size: 18pt, weight: "bold")[Inference],
      fill: none, stroke: none),

    // Edges — inputs to Control PC
    edge(<i-cam>, <pc-inference>, "-|>", label: lbl[USB]),
    edge(<i-pose>, <pc-inference>, "-|>", label: lbl[USB]),
    edge(<i-ff>, <pc-inference>, "-|>", stroke: disabled-edge),

    // Internal processing
    //edge(<feat>, <il>, "-|>"),

    // IL Policy → bridges
    //edge(<il>, <i-usb1>, "-|>", label: lbl[USB]),
    edge(<il>, <i-usb2>, "-|>", label: lbl[USB]),
    edge(<feat>, <dataset-rv-inf>, "-|>"),

    // Bridges → arm actions
    //edge(<i-usb1>, <i-ra>, "-|>", label: lbl[UART]),
    edge(<i-usb2>, <i-la>, "-|>", label: lbl[UART]),

    // ══════════════════════════════════
    //  DATA COLLECTION
    // ══════════════════════════════════

    // Inputs
    node((0, 4), [Cameras], ..sensor, name: <d-cam>),
    node((0, 5), [Pose], ..sensor, name: <d-pose>),
    node((0, 4.5), text(fill: c-disabled-text)[Force Feedback], ..disabled, name: <d-ff>),

    // Control PC
    node((1, 4.5), text(size: 9pt, fill: rgb("#64748b"))[Control PC],
      fill: none, stroke: none),
    node((1, 4), text(fill: c-core-text)[Data Collection], ..core, name: <dc>),
    node((1, 5), text(fill: c-core-text)[Control Passthrough], ..core, name: <cp>),
    node(
      enclose: (<dc>, <cp>),
      hide[.],
      fill: c-container, stroke: c-container-stroke + 1pt,
      corner-radius: 10pt, inset: auto,
      name: <pc-collection>
    ),

    node((2, 5), align(center, text(size: 9pt)[USB/UART  Bridges]), ..hw, name: <d-usb2>),

    // Outputs (boxed)
    node((3, 5), [Follower Pose], ..output, name: <d-la>),

    // Local Dataset
    node((2, 4.5), [Hugging Face Dataset], ..storage, name: <dataset-hf>),
    node((2, 4), [ReRun Library], ..storage, name: <dataset-rr>),
    node((3, 4), [ReRun Visualizer], ..storage, name: <dataset-rv>),

    // Feedback loop
    node((0, 6), hide[.], stroke: none, fill: none, inset: 0pt, name: <fbl>),
    node((3, 6), hide[.], stroke: none, fill: none, inset: 0pt, name: <fbr>),
    node((1.5, 5.8), text(weight: "medium")[Human Control Loop], name: <human-control>),
    node((1.5, 6.3), text(weight: "medium")[Leader Arm Pose],
      fill: c-fb, stroke: c-fb-stroke + 1.5pt,
      shape: shapes.rect, corner-radius: 8pt, inset: auto, name: <fb>),

    node(
      enclose: (<human-control>, <fb>),
      hide[.],
      fill: c-container, stroke: c-container-stroke + 1pt,
      corner-radius: 10pt, inset: 2pt,
      name: <fb-section>,
    ),

    // Section enclosure
    node(
      enclose: (<d-cam>, <d-pose>, <d-ff>, <d-la>, <dataset-rr>, <dataset-rv>, <fb-section>),
      hide[.], fill: c-bg, stroke: c-border + 1.5pt,
      corner-radius: 14pt, inset: 11pt, layer: -2,
    ),
    node((1.5, 3), text(size: 18pt, weight: "bold")[Data Collection],
      fill: none, stroke: none),

    // Edges — inputs to Control PC
    edge(<d-cam>, <pc-collection>, "-|>", label: lbl[USB]),
    edge(<d-pose>, <pc-collection>, "-|>", label: lbl[USB]),
    edge(<d-ff>, <pc-collection>, "-|>", stroke: disabled-edge),

    // Data Collection → Local Dataset
    edge(<dc>, <dataset-hf>, "-|>"),
    edge(<dc>, <dataset-rr>, "-|>"),
    edge(<dc>, <dataset-rv>, "-|>"),

    // Control Passthrough → bridges
    edge(<cp>, <d-usb2>, "-|>", label: lbl[USB]),

    // Bridges → arm actions
    edge(<d-usb2>, <d-la>, "-|>", label: lbl[UART]),

    // Feedback loop (dashed amber)
    edge(<fb>, <d-pose>, "-|>-", bend: 10deg,stroke: (dash: "dashed", paint: c-fb-stroke, thickness: 1.5pt)),
    edge(<d-la>, <fb>, "-|>-", bend: 10deg, stroke: (dash: "dashed", paint: c-fb-stroke, thickness: 1.5pt)),
  )
}
