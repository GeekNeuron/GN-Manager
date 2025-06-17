# 🚀 The GN Media Toolkit

<p align="center">
  <strong>An all-in-one command-line suite for managing, editing, and automating all your media needs.</strong>
</p>
<p align="center">
  Built upon the power of legendary open-source tools:
  <br>
  <strong>FFmpeg</strong> | <strong>yt-dlp</strong> | <strong>ImageMagick</strong>
</p>

---

## 📖 About This Project

The **GN Toolkit** is the result of an exploratory journey to challenge the maximum capabilities of command-line tools. What began as a simple need to merge files has evolved into a complete software suite with 16 distinct tools, capable of performing complex tasks including intelligent workflows, conditional processing, and full automation. This toolkit is designed for power users, media archivists, and anyone who seeks absolute control over their media files.

---

## ✨ Key Features

* **Total File Management:** Merge, compress, convert, and edit audio and video files.
* **Intelligent Automation:** Conditional and batch processing of files based on your quality standards.
* **Online & Subtitle Tools:** Download videos and subtitles from YouTube and quickly search subtitle websites.
* **Analysis & Extraction:** Rip audio, create high-quality GIFs, take screenshots, and display detailed technical specifications of media files.
* **Visual Processing:** Graphically analyze live audio waveforms and create cinematic storyboards from your videos.
* **Central Dashboard:** Access all tools from a single, user-friendly, and organized menu.

---

## ⚙️ Prerequisites & Setup (Launch Checklist)

To get the toolkit operational, please follow these three steps carefully.

### Step 1: Get The Scripts
Place all 16 script files (`.bat`) from this project into a new, single folder. This will be your toolkit's main directory.

### Step 2: Install The Galactic Engines
This suite relies on 3 core applications. Download them from the links below and place their executable files (`.exe`) in the **same folder** where you placed the scripts.

* **FFmpeg Suite (includes `ffmpeg`, `ffprobe`, `ffplay`):**
    * **Download Link:** [**Gyan.dev FFmpeg Builds (Full Release Version)**](https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z)
    * **Instructions:** After downloading, extract the `.7z` archive using a program like 7-Zip or WinRAR. Copy the **three files** `ffmpeg.exe`, `ffprobe.exe`, and `ffplay.exe` from the `bin` folder and place them in your toolkit directory.

* **yt-dlp (for YouTube Downloading):**
    * **Download Link:** [**yt-dlp.exe (Latest Release)**](https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe)
    * **Instructions:** Simply place the downloaded `yt-dlp.exe` file directly into your toolkit directory.

* **ImageMagick (for Image Processing):**
    * **Download Link:** [**ImageMagick Official Download Page**](https://imagemagick.org/script/download.php)
    * **Instructions:** Download and **install** one of the Windows versions.
    * **Crucial Installation Step:** During installation, make sure you check the box that says **"Add application directory to your system PATH"**. This is essential for the "Cinematic Scene Creator" tool to work correctly.

### Step 3: Final Systems Check
Your toolkit folder should now contain **16 script files** and **4 executable files** (`ffmpeg.exe`, `ffprobe.exe`, `ffplay.exe`, `yt-dlp.exe`). ImageMagick should be installed on your system.

---

## 🚀 The Tools

All tools are accessible from the main dashboard, `GN-Toolkit-v3-Final.bat`.

### 🌌 Workflows
> These are advanced meta-scripts that combine multiple tools into a single, intelligent workflow.

* `GN-Master-Downloader.bat`: Takes a YouTube URL, downloads the video and subtitles, compresses the video, and merges everything into a final, standardized file.
* `GN-Quality-Enforcer.bat`: Scans a folder and intelligently re-encodes only the files that do not meet your specified quality standards (codec, resolution).
* `GN-Scene-Creator.bat`: Creates a beautiful cinematic storyboard poster from your video by combining the power of FFmpeg and ImageMagick.

### 🛠️ Core Tools: Creation & Conversion
* `GN-Ultimate-Merger.bat`: Professionally merges video, audio, and subtitle files.
* `GN-Pro-Compressor.bat`: Compresses and converts videos with full control over quality (x265/x264).
* `GN-Audio-Converter.bat`: Converts audio files between various formats (MP3, AAC, etc.).

### ✂️ Editing & Extraction
* `GN-QuickFix.bat`: A tool for common fixes like rotating a video or adding a permanent watermark.
* `GN-Extractor.bat`: For ripping audio, creating high-quality GIFs, or taking a screenshot from a video.

### 🌐 Subtitle & Online Tools
* `GN-Subtitle-Downloader.bat`: Downloads subtitles in various languages from a YouTube link.
* `GN-Subtitle-Search.bat`: Quickly opens search results for a movie/series name in popular subtitle websites.
* `GN-Stream-Tester.bat`: Plays and tests live online streams, such as internet radio.

### 🔍 Analysis & Playback
* `GN-Inspector.bat`: Displays a clean, detailed technical specification sheet for any media file.
* `GN-Visual-Analyzer.bat`: Plays a media file while providing a live, graphical analysis of its audio waveform and frequency spectrum.
* `GN-Quick-Preview.bat`: A lightweight, borderless player for quick media previews. (Best used by dragging and dropping a file onto the script icon).

### 🤖 Automation
* `GN-Batch-Processor.bat`: A simple, fast automation tool to merge all same-named video and audio pairs in a folder.

---

## 💡 How to Use

The easiest way to start is by running the main launcher file: **`GN-Toolkit-v3-Final.bat`**.
This will present you with a central dashboard and a categorized menu, giving you access to all the other tools.

> For tools with unique functionality (like `GN-Quick-Preview.bat`, which is optimized for drag-and-drop), you can still use them independently as needed.

---
<p align="center">
  <em>This toolkit began with curiosity and evolved through collaboration. Enjoy exploring the endless universe of the command line!</em>
</p>
