# Zero - Strategy Game

[![GitHub](https://img.shields.io/github/license/hoishing/zero-game)](https://opensource.org/licenses/MIT)

<table id="img-tb">
<tr>
<td><img src="https://i.imgur.com/KDSdi7q.jpg" width="350" /></td>
<td><img src="https://i.imgur.com/eVXs5ZL.jpg" width="350" /></td>
</tr>
</table>

📲 Download from [app store](https://apps.apple.com/hk/app/zero-tbs/id1399856976)

Zero is a turn-based-strategy inspired by my favorite game [Sangokushi Sōsōden (三國志曹操伝)](https://en.wikipedia.org/wiki/Sangokushi_S%C5%8Ds%C5%8Dden).

I wonder how the game was made when I was a kid, and never lose the tempt to create something like that after being an app developer. After developing utility apps for years, I think I'm ready to ful-fill this little dream deep in my heart.

This is the biggest endeavour I've made as an "indie" so far. I design the game from ground up using Apple's 2D game engine [SpriteKit](https://developer.apple.com/spritekit/). Every element in the game including level design, sprites and animation, FX, coding, AI... are all created by myself. The only exception is audio, I purchase the level theme songs from [melody loops](https://www.melodyloops.com/), as I really don't think I can compose a satisfactory theme song on my own 😆

demo 🎬 https://youtube.com/shorts/w9o-ijtwV38

## Motivation

I create single-purpose utility apps for most of the time. Their UI are simple, and as common as possible for easy user pickup. So its an efficient choice for indie dev like me.

But I always wonder, am I able to create a game that I enjoy to play with?

Sure I can do "Flippy Bird Clones" kind of stuff but its meaningless because:

1. I couldn't learn much from that kind of project
2. I'm not creating something I enjoy to play with

I enjoy playing action and strategy games. Its natural to start with that.

My strength is more on coding instead of graphic and animation, I picked strategy game, as the chance of finishing the project seems much higher (yes, in real life project started often not completed... especially those big ones)

What do I expect to gain from this project?

- learn how to create 2D game with SpriteKit
  - coding game logic
  - manage game assets
  - create FX
- write the game AI from scratch <- the most challenging part to me

With the above "simple" expectations I target to finish the project in 3 months. It turns out finished in..... ONE YEAR 🤯 Full-time‼️

I knew as a toy project it doesn't make sense spending so much resources on it. However it really pushed my limits and bring my professional life to a whole new level. It forced me to deal with many areas that I fear to touch, such as graphics, game FX and AI. In turn I learn and experience so much from it. I'm so grateful that I insist 😌

## Technical Details

🔗 [source code](https://github.com/hoishing/zero-game)

### How did I make the game

Simply put, I create the game by using as much built-in features from SpriteKit as possible, avoid using 3rd party tools to create sprites, animation and FX. The decision is base on cost-effectiveness and the original purpose of learning Apple's game building technologies.

### AI

Before starting the project, I "imagine" I may using machine or deep learning to tackle the AI of the game. Later I found that it's overkill because all I really need is **Enumeration**! That is, loop through all possible steps of each pawn, and rank each step based on maximum damage to the opponents, or specific goal of the level.

The enumeration approach greatly simplify the AI development. It also reduced the hardware requirement so maximized the device computability.

### Game Level Design

I use Xcode built-in scene editor to create each level. It's fast and easy comparing other scene creation tools, and deeply integrate with other components in SpriteKit. That make scene manipulation much easier.

### Audio

- Sound FX: download from https://freesound.org
- Level theme songs: purchase from [Melody Loops](https://www.melodyloops.com/). They are not shared in this repo due to license limitation.

### Graphics

To keep things simple, the game used a "geometric style" design. Each basic geometric shape represent a character type: infantry, archer, medic, engineer...etc.

The magic / strategies are represented by pure symbol. It eliminated text communication with users, and thus the corresponding translation / i18n effort.

All graphic assets are designed with [Affinity Designer](https://affinity.serif.com/en-us/designer/), then export as vector graphic(SVG) for lossless scaling between different devices resolution.

### FX

Using Xcode built-in particle emitter, with sprite atlas putting in `xcassets` file. The particle system in Xcode is quite primitive comparing with other dedicated particle tools. So the FX can be created are indeed quite limited. However, the FX required by this game is relatively simple, that make it a cost-effective choice.

## Questions?

Open a [github issue](https://github.com/hoishing/zero-game/issues) or ping me on [Twitter](https://twitter.com/hoishing) ![](https://api.iconify.design/logos/twitter.svg?width=20)
