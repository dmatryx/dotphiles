dotphiles
=========

  1. Clone your fork.

     `git clone --recursive git@github.com:*username*/dotphiles.git ~/.dotfiles`

  2. Edit `dotsyncrc` and enable dotfiles to use.

  3. Run dotsync `./.dotfiles/dotsync/bin/dotsync -L`

  4. Start a new login shell.

Configuration
-------------

### dotfiles

These are the minimum files you'll want to edit

  - `dotsyncrc` settings for [dotsync][2]
  - and any dotfiles you enable in `dotsyncrc`

### terminal

dotphiles uses the [base16][5] color theme
by default, install the colour schemes for your terminal.
See `deploy/terminal`

### deploy

  - `deploy/osx` setup osx and install ports & brews (only use one)
  - `deploy/linux` setup linux and install packages
    - `packages/macports` add ports to be installed by `osx` (select one)
    - `packages/homebrew` add brews to be installed by `osx` (select one)
    - `packages/apt` add packages to be installed by `linux` on apt based systems

### dotsync

See the documentation for [dotsync][2] for more information.

  - dotsyncrc

    Add dotfiles to `dotsyncrc` like

        [files]
        ...
        dotfile
        dir
        dir/dotfile
        ...
        [endfiles]

    dotsync will look for

         ~/$DOTFILES/dotfile.d/localhost
         ~/$DOTFILES/dotfile.d/$HOSTNAME
         ~/$DOTFILES/dotfile.d/$DZHOST
         ~/$DOTFILES/dotfile.d/$DOMAIN
         ~/$DOTFILES/dotfile

   And link the first one it finds instead of the standard dotfile.  The
   `localhost` dotfile will be excluded from your repo.

   $DZHOST is passed to remote hosts and contains the hostname as entered in `dotsyncrc`

  - Usage

    Dotsync can be used to link your dotfiles into place

    - `dotsync -L` symlink dotfiles into place
    - `dotsync -U` update from github

    And update remote machines

    - `dotsync -I -H hostname` initialise *hostname* with the set of dotfiles
    - `dotsync -U -H hostname` update dotfiles on *hostname* from github
    - `dotsync -I -H hostname -r` initialise *hostname* with the set of
      dotfiles with rsync
    - `dotsync -U -H hostname -r` update dotfiles on *hostname* with rsync
    - `dotsync -A` update dotfiles on **all hosts**

  - Backups

    Any existing ~/.dotfiles will be backed up into `~/.backup/dotfiles/` if
    found

Editing
-------

When you edit your dotfiles, you should commit the changes to git with

    git commit -a

And periodically push the changes to github

    git push

Updating
--------

To keep your fork upto date with additions to the dotphiles repo, do the following

    cd ~/.dotfiles
    git remote add upstream https://github.com/dotphiles/dotphiles
    git fetch upstream
    git merge upstream/master