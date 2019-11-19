# emoji-thief
### _ava fox_

A program that downloads custom emoji from mastodon/pleroma servers

## Installation

Download a binary from the releases page

or

clone this repo, [cl-cwd](https://github.com/inaimathi/cl-cwd), and [with-user-abort](https://github.com/theZacAttacks/with-user-abort) into your local projects

```
mkdir ~/common-lisp
git clone https://github.com/theZacAttacks/with-user-abort
git clone https://github.com/inaimathi/cl-cwd
git clone https://github.com/theZacAttacks/emoji-thief
```

run `make` in the `~/common-lisp/emoji-thief` folder.

note: you'll need a lisp implementation installed (or use [roswell](https://github.com/roswell/roswell))

## Usage

```
./steal --help
./steal mastodon.social
./steal -v -o mastodon_emojis mastodon.social
```

or (from lisp)

`(ql:quickload :emoji-thief)`

`(thief:get-all-emojis "mastodon.social")`

## License

NPLv1+

