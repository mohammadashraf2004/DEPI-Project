import streamlit as st
import os
import numpy as np
import pickle
from keras.models import load_model
from keras.preprocessing.sequence import pad_sequences

# File paths
model_path = 'models/model.h5'
tokenizer_path = 'models/tokenizer.pkl'

# Error handling for model loading
try:
    if os.path.exists(model_path):
        model = load_model(model_path)
    else:
        st.error("Model file not found. Please check the model file path.")
except Exception as e:
    st.error(f"Error loading model: {e}")

# Error handling for tokenizer loading
try:
    if os.path.exists(tokenizer_path):
        with open(tokenizer_path, 'rb') as tokenizer_file:
            tokenizer = pickle.load(tokenizer_file)
    else:
        st.error("Tokenizer file not found. Please check the tokenizer file path.")
except Exception as e:
    st.error(f"Error loading tokenizer: {e}")

# Sentiment labels and custom threshold
CUSTOM_THRESHOLD = 0.5

# Predict sentiment function
def predict_sentiment(text, maxlen=100):
    try:
        sequence = tokenizer.texts_to_sequences([text])
        padded_sequence = pad_sequences(sequence, maxlen=maxlen)

        prediction = model.predict(padded_sequence)
        predicted_probability = prediction[0][0]

        sentiment_label = "Positive" if predicted_probability >= CUSTOM_THRESHOLD else "Negative"

        return sentiment_label, predicted_probability
    except Exception as e:
        st.error(f"Error during prediction: {e}")
        return None, None

# Streamlit UI
st.set_page_config(page_title="Sentiment Analysis", layout="centered")

# Change background color
st.markdown(
    """
    <style>
    .stApp {
        background-color: 	#151B54;  /* Light blue background */
    }
    </style>
    """,
    unsafe_allow_html=True
)

st.title("Sentiment Analysis")

# User input 
user_input = st.text_input("Enter text for sentiment analysis:", placeholder="Type your text here...")

if user_input:  # Check if input not empty
    sentiment, conf = predict_sentiment(user_input)
    if sentiment:
        emoji = "😀" if sentiment == "Positive" else "😢"
        st.write(f"The sentiment of the text is: **{sentiment} {emoji}**")
        st.write(f"Confidence percentage is: **{conf * 100:.2f}%**")
    else:
        st.error("An error occurred during sentiment analysis.")
else:
    st.warning("Please enter a text to analyze.")
