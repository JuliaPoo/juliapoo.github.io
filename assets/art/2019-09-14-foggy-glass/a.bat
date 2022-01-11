ffmpeg -y -i 1.mp4 -t 10 -filter_complex "scale=300:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse=dither=bayer" preview.gif

ffmpeg -i 1.mp4 -filter_complex "scale=300:-1" -vframes 1 1-preview.png