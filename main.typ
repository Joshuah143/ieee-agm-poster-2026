#import "@preview/peace-of-posters:0.5.6" as pop
#import "src/sys_arch.typ": sys-arch-diagram
#import "src/inference.typ": inference-diagram

#let UBC_blue = rgb(12, 35, 68)
#let outset_buffer = 5cm

#set page(
  width: 48in,
  height: 36in,
  margin: 0.5in,
)
#pop.set-poster-layout(pop.layout-a0)

#set text(font: "Noto Sans", size: pop.layout-a0.at("body-size"))
#let box-spacing = 1.2em
#set columns(gutter: box-spacing)
#set block(spacing: box-spacing)
#pop.update-poster-layout(spacing: box-spacing, body-size: 22pt)
// #pop.title-box(logo: )

#let theme = (
    body-box-args: (
        inset: 0.6em,
        width: 100%,
    ),
    body-text-args: (:),
    heading-box-args: (
        inset: 0.6em,
        width: 100%,
        fill: UBC_blue, // rgb(255, 25, 255)
        stroke: rgb(25, 25, 25),
    ),
    heading-text-args: (
        fill: white,
    ),
    title-box-args: (
      inset: 1cm,          // keeps text padded inward
      outset: (top: outset_buffer, left: outset_buffer, right: outset_buffer),  // extends background to page edges
      width: 100%,
      fill: UBC_blue,  // your header color
    ),
  )  
)

#pop.set-theme(theme)


#pop.title-box(
  "Machine Learning for Robotic Napkin Folding",
  authors: [Joshua Himmens#super("1"), Sloan Sobie#super("2"), Dawson March#super("2"), Genevieve Merz#super("3"), Cameron Powell#super("3"), Jaden Legate#super("3")],
  institutes: [#super("1")*UBC Engineering Physics*, #super("2")UBC Mechanical Engineering, #super("3")UBC Sauder School of Business],
  // keywords: "Robotics, Machine Learning, LeRobot, Open-Source-Software",
  logo: image("assets/actually_white_fizz_logo.svg", height: 6cm),
  text-relative-width:70%
  // institutes-size: cm
)

#columns(3,[
//   #pop.column-box(heading: "Abstract")[

// Robotic manipulation of deformable objects remains challenging because cloth has high-dimensional configurations, frequent self-occlusion, and strong sensitivity to grasp location. This project investigates whether a low-cost bimanual robot platform can learn to pick up and fold a napkin from human demonstrations using imitation learning. Our system consists of two open-source SO-101 robotic arms (costing under \$300 each), three RGB cameras (one overhead and two arm-mounted), and policies trained in LeRobot on over 400 episodes (~5 hours) of demonstrated pickup and folding episodes.
    


//   ]

  #pop.column-box(heading: "Motivation")[

    Robotics and robotics control are becoming increasingly capable and inexpensive due to simultaneous innovations in robotic control and the cost of robotics hardware. Our team hopes to leverage these advances in robotics technology to develop commercial products which are able to reduce menial labour. Specifically, we are exploring the application of the open-source and low-cost SO-101 arms from The Robot Studio and Hugging Face to the domain of napkin folding. 

    Napkin folding is a technically and commercially interesting application for two primary reasons:
    + Thousands of hours are spent annually by service staff in fine dining establishments, making it a problem of significance.
    + While many similar problems are solved through reinforcement learning (RL), deformable materials like linen napkins are notoriously hard to both simulate and use policies trained in simulation (sim-to-real gap) due to their highly non-linear dynamics.
  ]

  #pop.column-box(heading: "Policy Choice")[

    There are many choices of policies which might be suitable for this task. As discussed previously, as deformable materials are involved, our policy cannot be trained in simulation. Due to this constraint, it is initially imperative to leverage imitation learning or behaviour cloning models, as reinforcement models would take unsuitably long times to train. 

    As shown by Zhao et al @zhao2023learning, an action chunking with transformers (ACT) policy is likely suitable for this type of task. ACT is well-suited for this task as it only requires a few episodes (\~30), and can train in under 24 hours.

    A current trend in robotic control is the use of vision-language-action (VLA) models, which also use transformers. While VLAs are often more performant, they require significantly more data and compute. @chen2025sarm VLA-type policies have also been shown to transfer between tasks and robotic systems well. For this reason, there is significant focus in the industry to further develop them; their size and complexity make them unsuitable for this task. @dyna2026dyna1research


    
  ]

  #pop.column-box(heading: "Data Collection Setup")[In order to minimize distribution shift, a data-collection jig was fabricated from aluminum extrusions and composite wood to mount one overhead camera, lights, and all four arms. Data was collected by having a human control the leader arms, which would have their pose imitated by the follower arms in real time.
    
    #figure(
  scale(2000%, image("assets/setupv3.svg"),reflow: true),
  caption: [Data Collection Platform]
)
Collected data is saved both locally and backed up to the UBC Sockeye research cloud. It has been made publicly available through Hugging Face. @joshua_himmens_2026

]
  


  #pop.column-box(heading: "Methods", )[
    
    #figure(
      scale(180%, sys-arch-diagram(),reflow: true),
      caption: [System Architecture],
    )
    #figure(
      image("assets/example_visual_data.png"),
      caption: [Example Visual Information Collected]
    )

  In order to provide sufficient data, 499 episodes were collected, totalling over 550k images at 30 frames per second. This data was split between full-task data (400 episodes, \~4 hours) and pickup data (99 episodes, \~1 hour) as initial models showed that the policy struggled to learn the pickup phase.

    
  ]

  #pop.column-box(heading: "Policy Training")[
    Training was conducted locally, on the public cloud, and on a UBC HPC cluster, but local training was shown to have the fastest development cycle due to reduced data transmission and job initialization overhead.

    #figure(
      image("assets/loss_plot.png", width: 70%),
      caption: [Training loss over 100k steps (~15 h)]
    )

    The loss curve, while difficult to mechanistically interpret, indicates that the policy is learning and that it is unlikely that there are any critical errors in the data collection or training scripts that prevent the model from navigating the loss landscape.
    
  

   
  ]

  #pop.column-box(heading: "Results and Analysis")[
    #figure(
  scale(140%, inference-diagram(),reflow: true),
  caption: [Inference Diagram]
)

    #figure(
      image("assets/complete-fold-overhead.jpeg", height: 10cm),
      caption: [Example Successful Fold]
    )
    // Initial results show that the learned policy can execute parts of the folding sequence once a stable grasp has been achieved, but performance degrades significantly when the napkin enters an out-of-distribution pose. These results suggest that, in deformable object manipulation, robust perception and pickup are more significant bottlenecks than later-stage folding motion. This work demonstrates an accessible platform for studying learned bimanual cloth manipulation and highlights the challenge of generalization in vision-based robot policies. Ongoing work compares multiple policy classes, including transformer-based and diffusion-based approaches, and the role of learned reward modelling, using a napkin fold quality metric to evaluate task success. '

    // ^^ from the abstract, maybe talk about how the napkins rarely make it to the fully-folded state because it struggles on pickup. A policy trained only on pickup picks up almost always, the only full-data (if you help it grab the napkin) works all the time, but a policy trained on both is still not successful. Indicates that data may not be clean, may be shifted, distribution might be large.. idk man, something like that

    // CHAT:

    // Initial experiments indicate that pickup, not folding, is the dominant failure mode. A policy trained only on pickup achieved reliable grasps, while the full-task policy could complete the fold sequence when the napkin was manually placed into a good initial grasp state. However, the end-to-end policy trained on both pickup and folding remained inconsistent. This suggests that errors introduced during pickup propagate through the rest of the task and that the combined dataset likely contains substantial state variation and distribution shift.

    // These results imply that, for deformable object manipulation, improving grasp robustness and data consistency is likely more important than increasing folding policy complexity alone. The platform nevertheless demonstrates that low-cost bimanual hardware can learn meaningful cloth manipulation behavior and provides a practical testbed for comparing ACT with newer policy and reward-modeling approaches.

    // CLAUDE:

    Initial results show that the learned policy can execute the folding sequence once a stable grasp has been achieved, but performance degrades significantly when the napkin enters an out-of-distribution pose. Critically, the napkin rarely reaches the fully-folded state because the policy struggles during pickup. To isolate this bottleneck, we trained separate policies on pickup-only and fold-only data subsets. The pickup-only policy grasps successfully in nearly all trials, and the fold-only policy (given a human-assisted grasp) completes the fold reliably. However, a single policy trained on the full task fails to compose these stages, suggesting that the combined distribution is too broad for the ACT model to capture at this dataset scale, or that distributional shift between the pickup and folding phases creates conflicting action modes.
    
  ]

  

  #pop.column-box(heading: "Conclusion")[
    // The partial success of the ACT policy indicates that the policy is lacking in compute, model complexity, dataset distribution width, or dataset depth. As the model was observed not to learn appreciably after 200k steps, we believe that more training time and compute will not appreciably change the model's success rate.

    // CLAUDE: 

    // The partial success of stage-isolated policies, combined with the failure of the unified policy, indicates that the bottleneck is not raw training compute — the model showed no appreciable improvement beyond 200k steps — but rather the complexity of the joint pickup-and-fold distribution.  

    // CHAT: 
    
    This work shows that low-cost imitation learning can produce partial success on robotic napkin folding, but robust end-to-end performance is still limited by the pickup stage. Since training loss plateaued without corresponding task success, the main bottleneck is unlikely to be additional compute alone; dataset quality, distribution coverage, and stage-specific supervision are more probable limitations.


    Future work will explore stage-aware policy architectures such as SARM to explicitly decompose the task, SmolVLA to leverage pretrained vision-language representations for better generalization, and learned reward modeling to provide a continuous napkin fold quality metric beyond binary success.
    Together, these steps should clarify whether improved data and task decomposition are sufficient to achieve reliable full-fold execution.
    
    
  ]

  #pop.column-box()[
    #bibliography("bibliography.bib", style: "ieee")
  ]

])
#let spacing = 10pt
#pop.bottom-box(
  stack(dir: ltr, 
		box(width: 20cm, [
            #set text(size: 30pt)
			IEEE Vancouver Section AGM
			#linebreak()
			March 28th, 2026
		]),),
  heading-box-args: (
    inset: 1cm,
    outset: (bottom: outset_buffer, left: outset_buffer, right: outset_buffer),
    width: 100%,
    fill: UBC_blue,
    ),
)

