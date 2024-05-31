# ide

This is my **personal development environment** (PDE) based on [`fish`][fish], [`neovim`][neovim], [`mise`][mise] and [`docker`][docker].

## programs

### [`docker`][docker]

All my workflow revolves around running containers for my services. So, for now, I'm still using [`docker`][docker] and their extensions, mainly, [`compose`][docker-compose] to define those services.

#### kubernetes

I still need to learn a lot about it, but to make navigation between contexts and namespaces easier, I'm using [`kubie`][kubie].

In the near future I want to experiment with [`k3d`][k3d] and [`tilt`][tilt] to make simulations about my system environment easier to reproduce locally, and the transition to production smoother.

### terminal

For the terminal, that's the place were I spent most of time, the following is used:

* [`fish`][fish]: there is nothing fancy about it
* [`starship`][starship]: this is what makes my shell beautiful
* [`zoxide`][zoxide]: change between directories has never been easier
* [`eza`][eza]: just to make `ls` informative and interesting
* [`bat`][bat]: a better `cat`
* [`ripgrep`][ripgrep]: a better `grep`
* [`tmux`][tmux]: handling multiple panes, windows, and sessions is a must in my workflow
  * among the aspects to improve, one that is on my sight is the integration with [`neovim`][neovim]
* [`tmuxp`][tmuxp]: to manage my different sessions
  * I still want to give a try to [`tmux-resurrect`][tmux-resurrect] and [`tmux-continuum`][tmux-continuum]

### programming languages

In my day-to-day I use:

* `elixir`
* `python`
  * with `poetry` handling dependencies, whenever is possible
* `javascript` + `node`

[fish]: https://fishshell.com/
[neovim]: https://neovim.io/
[mise]: https://mise.jdx.dev/
[docker]: https://www.docker.com/
[docker-compose]: https://docs.docker.com/compose/
[kubie]: https://github.com/sbstp/kubie
[k3d]: https://k3d.io/
[tilt]: https://tilt.dev/
[starship]: https://starship.rs/
[zoxide]: https://github.com/ajeetdsouza/zoxide
[eza]: https://eza.rocks/
[bat]: https://github.com/sharkdp/bat
[ripgrep]: https://github.com/BurntSushi/ripgrep
[tmux]: https://github.com/tmux/tmux/wiki
[tmuxp]: https://tmuxp.git-pull.com/
[tmux-resurrect]: https://github.com/tmux-plugins/tmux-resurrect
[tmux-continuum]: https://github.com/tmux-plugins/tmux-continuum
