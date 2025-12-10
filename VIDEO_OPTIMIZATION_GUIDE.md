# Video Optimization Guide for Environment Scan Card

## Current Situation
- Your video: **18MB** (quite large for web)
- Display size: **200px height** (in pipeline card)
- Existing videos: **2-7MB** (much smaller)

## Recommended Approach

### 1. Compress the Video

Use the provided `compress_video.sh` script:

```bash
./compress_video.sh your_18mb_video.mp4 reconstruction_input_videos/your_optimized_video.mp4
```

**What it does:**
- Reduces resolution to 480p (854x480) - more than enough for 200px display
- Uses H.264 codec (best browser compatibility)
- Sets bitrate to ~1.5 Mbps (should reduce 18MB to ~2-4MB)
- Adds `faststart` flag for progressive download
- Maintains good visual quality

**Expected result:** 18MB → **2-4MB** (75-85% reduction)

### 2. Alternative: More Aggressive Compression

If you want even smaller (1-2MB), use this command:

```bash
ffmpeg -i your_18mb_video.mp4 \
    -c:v libx264 \
    -preset slow \
    -crf 32 \
    -vf "scale=640:360:force_original_aspect_ratio=decrease" \
    -maxrate 800k \
    -bufsize 1.6M \
    -c:a aac \
    -b:a 96k \
    -movflags +faststart \
    -pix_fmt yuv420p \
    output.mp4
```

### 3. HTML Optimization

Update the video tag in `index.html` (line 185) to add `preload="metadata"`:

**Before:**
```html
<video src="./reconstruction_input_videos/1.mp4" autoplay muted loop playsinline></video>
```

**After:**
```html
<video src="./reconstruction_input_videos/your_video.mp4" autoplay muted loop playsinline preload="metadata"></video>
```

**Why `preload="metadata"`:**
- Only loads video metadata initially (not full video)
- Reduces initial page load time
- Video starts downloading when user scrolls near it
- Still allows autoplay when visible

### 4. Optional: Lazy Loading with Intersection Observer

For even better performance, you can lazy load videos only when they're about to enter the viewport. Add this to your HTML:

```html
<video 
    src="./reconstruction_input_videos/your_video.mp4" 
    autoplay 
    muted 
    loop 
    playsinline 
    preload="none"
    data-src="./reconstruction_input_videos/your_video.mp4">
</video>
```

Then add JavaScript (in the `<script>` section):

```javascript
// Lazy load videos when they enter viewport
document.addEventListener('DOMContentLoaded', () => {
    const videos = document.querySelectorAll('video[data-src]');
    const videoObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const video = entry.target;
                video.src = video.dataset.src;
                video.removeAttribute('data-src');
                videoObserver.unobserve(video);
            }
        });
    }, { rootMargin: '50px' });
    
    videos.forEach(video => videoObserver.observe(video));
});
```

## Quick Start

1. **Compress your video:**
   ```bash
   ./compress_video.sh your_18mb_video.mp4 reconstruction_input_videos/scan_video.mp4
   ```

2. **Update HTML** (line 185 in `index.html`):
   ```html
   <video src="./reconstruction_input_videos/scan_video.mp4" autoplay muted loop playsinline preload="metadata"></video>
   ```

3. **Test the result:**
   - Check file size: `ls -lh reconstruction_input_videos/scan_video.mp4`
   - Open the page and check Network tab in browser DevTools
   - Video should load much faster!

## Compression Settings Explained

- **`-crf 28`**: Quality setting (18-28 is good for web, lower = better quality but larger file)
- **`scale=854:480`**: Resolution (480p is sufficient for 200px display)
- **`-maxrate 1.5M`**: Maximum bitrate (controls file size)
- **`-movflags +faststart`**: Moves metadata to beginning for faster playback start
- **`-preset slow`**: Better compression (slower encoding, smaller file)

## Expected Performance

- **Before:** 18MB video → ~3-6 seconds load on fast connection
- **After:** 2-4MB video → ~0.5-1 second load on fast connection
- **Mobile:** Even bigger improvement on slower connections

## Need Help?

If compression doesn't work well or you need different settings, adjust:
- `-crf` value (lower = better quality, higher = smaller file)
- Resolution (`scale=640:360` for smaller, `scale=1280:720` for larger)
- Bitrate (`-maxrate 1M` for smaller, `-maxrate 2M` for larger)

