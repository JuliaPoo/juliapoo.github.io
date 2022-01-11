::ffmpeg -y -i 1.gif -filter_complex "scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=16[p];[s1][p]paletteuse=dither=bayer" _preview.gif

::ffmpeg -i 1.gif -vframes 1 1-preview.png
::ffmpeg -i 2.gif -vframes 1 2-preview.png
::ffmpeg -i 3.gif -vframes 1 3-preview.png
::ffmpeg -i 4.gif -vframes 1 4-preview.png

ffmpeg -i 1.gif -vcodec libx264 -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" 1-com.mp4
ffmpeg -i 2.gif -vcodec libx264 -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" 2-com.mp4
ffmpeg -i 3.gif -vcodec libx264 -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" 3-com.mp4
ffmpeg -i 4.gif -vcodec libx264 -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" 4-com.mp4