from gtts import gTTS

def text_to_speech(text, output_file):
    
    try:
        # Create a gTTS object with the given text and language
        tts = gTTS(text=text, lang='en')
        
        # Save the audio file
        tts.save(output_file)
        print(f"Audio saved as {output_file}")
    except Exception as e:
        print(f"An error occurred: {e}")