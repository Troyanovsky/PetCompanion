# PetCompanion

## English Intro

### Overview
Because I love my pet Luna so much, I wanted to have it accompany me while I work. So I created this app. If you find her cute, you can add her to your desktop too! (Or you can replace the sprite images with your own design/pet so you have your own pet companion!)

PetCompanion is a macOS desktop app that brings a cute virtual pet to your desktop. With a modular and well - structured codebase, it offers a variety of features including customizable pet behaviors, smooth animations, and intuitive user interactions.

### Features
1. **Configuration Management**: Supports loading configurations from the bundled `config.json` file or a user - editable configuration file, allowing users to customize pet behaviors easily.
2. **Animation Management**: Loads and plays pet animation frames according to different states, supporting both sequential and random playback.
3. **Movement Management**: Automatically updates the pet's position based on the configured speed, and handles boundary checks and drag events.
4. **State Management**: Uses a state machine to manage the pet's state transitions, automatically switching states based on state durations and events.
5. **User Interaction**: Enables users to control the display and hiding of the pet through the menu bar icon, and provides the option to open the configuration file for editing.

### Installation
1. Clone the repository to your local machine.
2. Open the `PetCompanion.xcodeproj` file in Xcode.
3. Build and run the project.

### Usage
- After launching the application, a menu bar icon and the pet companion will appear. You can click on menu bar icon to show or hide the pet.
- To customize the pet's behavior, click on "Open Config File" in the menu bar to edit the configuration file.

### Contributing
If you would like to contribute to this project, please fork the repository and submit a pull request.

### To-do
- Add my other cute daughter Zumi as an option

## 中文介绍

### 概览
我有一只叫 Luna 的小阿比猫咪，她经常在我工作的时候到我身边来陪着我，所以我做了这个小 app，让我在公司不在她身边的时候也可以看到她。如果你也觉得她很可爱，你也可以把她添加到你的桌面上！（或者你可以替换里面图像，来用你自己的设计或宠物，这样可以让你自己的宠物陪着你啦！）

PetCompanion 是一个 macOS 桌面应用，可以在桌面上展示一只可爱的虚拟宠物。提供了丰富的功能，包括可自定义的宠物行为、流畅的动画效果以及直观的用户交互体验。

### 功能特点
1. **配置管理**：支持从自带的 `config.json` 文件或用户可编辑的配置文件加载配置，方便用户自定义宠物行为。
2. **动画管理**：根据不同的状态加载并播放宠物动画帧，支持顺序播放和随机播放模式。
3. **移动管理**：根据配置的速度自动更新宠物位置，处理边界检查与拖拽事件。
4. **状态管理**：使用状态机管理宠物的状态转换，根据持续时间和事件自动切换状态。
5. **用户交互**：用户可以通过菜单栏图标控制宠物的显示与隐藏，同时可以选择打开配置文件进行编辑。

### 安装方法
1. 将仓库克隆到本地。
2. 在 Xcode 中打开 `PetCompanion.xcodeproj` 文件。
3. 构建并运行项目。

### 使用方法
- 启动应用后，菜单栏会出现一个图标，并且宠物伙伴也会出现在桌面上。点击菜单栏图标可以显示或隐藏宠物。
- 若要自定义宠物行为，可在菜单栏中点击“打开配置文件”进行编辑。

### 贡献
如果你希望为本项目做出贡献，请先 fork 仓库，然后提交 pull request。

### 计划
- 添加我的另一只可爱猫咪 Zumi
