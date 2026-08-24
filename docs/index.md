---
icon: lucide/rocket
hide:
  - toc
---

# Landing

This site acts as a collection of notes, technical documents, and stuff like that.

Find the relevant pages on the sidebar.

Some projects I have worked on or am working on:

## :lucide-gamepad-2: Elite Dangerous

<div class="grid cards" markdown>

-   ### Gankers.org :fontawesome-brands-react: :fontawesome-brands-typescript:
    [:lucide-globe-2: Demo](https://gankers.org){ .md-button .md-button--primary }
    [:fontawesome-brands-gitlab: Code](https://gitlab.com/gankers/gankers-frontend){ .md-button  }

    !!! success "Active Maintenance"

    Created after the existing solution by RoA was shutdown, Gankers.org provides a Killtracker for PVP Kills in Elite: Dangerous.
    The Data is entirely user-driven and at a quality where it is used as an authoritative source by PVPers, Gankers, PVErs and Carebears alike.

    Used and trusted by over 200 CMDRs.

-   ### Gankers.org API :fontawesome-brands-rust: :fontawesome-brands-postgresql:
    [:fontawesome-brands-gitlab: Code](https://gitlab.com/gankers/gankers-backend){ .md-button  }

    !!! success "Active Maintenance"

    The Backend running `gankers.org`. Written in Rust and using Postgres as the backing data-layer.

    The Backend contains both a REST/HTTP component implemented with `axum` and a gRPC Server with `prost`/`tonic`.
    Interactions with the DB are done using the magnificent `sqlx` crate.

-   ### EDSY-Shortener :fontawesome-brands-rust: :fontawesome-brands-typescript: :fontawesome-brands-postgresql:
    [:lucide-globe-2: Demo](https://ships.gankers.org){ .md-button .md-button--primary }
    [:fontawesome-brands-gitlab: Code](https://gitlab.com/CMDR-WDX/edsy-shortener){ .md-button  }

    !!! success "Active Maintenance"

    Shortlinking Services specifically implemented for [edsy.org](https://edsy.org), a ship-planning website for Elite: Dangerous.

    It's value proposition is that it takes the build link, evaluates it server side to determine key build metadata and then serves it such that social media sites like Discord will embed the link with rich metadata. See `README.md` in the Code Section for more info.

-   ### EDMC_PVP_Bot :fontawesome-brands-python:
    [:fontawesome-brands-gitlab: Code](https://gitlab.com/gankers/EDMC-PvPBot){ .md-button  }

    !!! success "Stable / Active Development"

    This is the [EDMC](https://github.com/EDCD/EDMarketConnector) Plugin that feeds `gankers.org` with data.

    It is run by many players and submits kills and deaths to the Gankers Backend.

-   ### elite-dangerous-plugin-framework :fontawesome-brands-rust:
    [:lucide-book: Docs](https://elite-dangerous-plugin-framework.github.io/){ .md-button .md-button--primary  }
    [:fontawesome-brands-github: Code](https://github.com/Elite-Dangerous-Plugin-Framework/elite-dangerous-plugin-framework){ .md-button  }

    !!! danger "Discontinued"

        Major improvements to EDMC's stability and planned features make EDPF's value proposition obsolete.

    EDPF started as an attempt to improve upon EDMC by using Tauri instead of Python/tk. It got really far, to the point of being able to load plugins at runtime and have them receive journal events.

    However, due to race conditions that were hard to debug, especially on webkitgtk, the project got put on hold, while EDMC made major improvements in what they plan for Plugin Registries.

    I urge you to read the internal documentation, as there is loads to learn about how one can (ab)use Tauri by turning it into a Plugin runner.

-   ### EDMC_Massacre :fontawesome-brands-python:
    [:fontawesome-brands-youtube: Demo](https://www.youtube.com/watch?v=EA4o3PSXSFk){ .md-button  }
    [:fontawesome-brands-github: Code](https://github.com/CMDR-WDX/EDMC-Massacres){ .md-button  }
    !!! warning "Finished / No Active Support"

    Helper-Plugin that helps players with more efficiently stacking Massacre-type missions in Elite: Dangerous. See attached Demo video for more context.

    No longer being worked on due to loss of interest, but also due to the existing version being "finished".

    If you are interested in how it works or how to stack Massacre Missions, please don't hesitate to look at the Demo linked above.

</div>