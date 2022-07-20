# RealityKit-Sampler

RealityKitSampler is a sample collection of basic functions of RealityKit, Apple's AR framework for iOS.

<img width="200" alt="スクリーンショット 2021-06-22 6 25 04" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/235259/fe1a0cf4-eb15-83bf-1abf-7614d1cccf5a.png">

## How to build
1, Download or Clone this project and open in xcode.

2, Please change the "Team" field of xcode Signing and Capabilities to your account.

3, Build on your actual device. This project can not be used in Simulators.

## Contents

### Put the box

<img width="200" alt="スクリーンショット 2021-06-22 6 25 04" src="https://user-images.githubusercontent.com/23278992/122830079-cc028c80-d322-11eb-87a3-8aa4803860a4.png">

The simplest way to use the ModelEntity and AnchorEntity.


### Gigant Robots

<img width="200" src="https://user-images.githubusercontent.com/23278992/124874290-83292400-e002-11eb-948f-13302a5806ed.gif">

Use USDZ models and animations.


### Big monitor

<img width="200" src="https://user-images.githubusercontent.com/23278992/123641992-c8f52800-d85d-11eb-918a-4619071a54c9.gif">

How to select a video from your album and paste it as a texture.


### Building blocks

<img width="200" src="https://user-images.githubusercontent.com/23278992/123644152-11ade080-d860-11eb-828f-68e86ac8ee28.gif">

How to place objects of different shapes and colors.


### Speech Balloon



Visualiing facial expressions and what you say.

### Special Move


Interact body and AR object.

### Face Cropper

<img width="200" src="https://user-images.githubusercontent.com/23278992/124336683-e158a000-dbd9-11eb-8a00-5c2943daefcb.gif">

Detect a face then crop.


### AR Hockey

<img width="200" src="https://user-images.githubusercontent.com/23278992/137721587-cc6e8235-b7a0-4fb1-ad12-4af3c1cbb5e9.gif">

Multi Device AR Game.

### Hand Interaction

<img width="200" src="https://user-images.githubusercontent.com/23278992/125152071-59e4d100-e185-11eb-8f4c-e14a825ada09.gif">

AR with Vision Framework.


## What you can learn

| Content | Technical Elements |
| ------------- | ------------- |
| **Put the box**  | ARView in SwiftUI, Scene, Entity, Anchor, MeshResource, Material.  |
| **Big Robots**  | USDZ, Animation  |
| **Big Monitor**  | VideoMaterial, SceneEvent  |
| **Building Block** | Ray Cast, Hit Test, Handle Gestures, Physics, Collision, TextureResource |
| **Speech Balloon** | Face Anchor, ARSessionDelegate, Deal with RealityComposer |
| **Special Move** | Body Anchor |
| **Face Cropper** | Image Anchor |
| **AR Hockey** | Collaborative Session |
| **Hand Interaction** | addForce, use with Vision |


## Author

Daisuke Majima

Freelance iOS programmer from Japan.

PROFILES:

WORKS:

BLOGS:  [Medium](https://rockyshikoku.medium.com/)

CONTACTS:  rockyshikoku@gmail.com

## Special Thanks

Inspired by:  [ARKit-Sampler](https://github.com/shu223/ARKit-Sampler)

Sound effect: [zapsplat](https://www.zapsplat.com)
