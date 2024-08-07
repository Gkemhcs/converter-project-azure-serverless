import ffmpeg

def audio_to_video(input_video_path,output_audio_path):
     

    video_stream = ffmpeg.input(input_video_path)
    audio_stream = ffmpeg.output(video_stream, output_audio_path, format="mp3")
    ffmpeg.run(audio_stream)
    
