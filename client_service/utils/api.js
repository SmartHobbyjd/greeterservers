// utils/api.js
import axios from 'axios';

const API_BASE_URL = 'http://localhost:8585'; // Update with your Go client service address

const api = axios.create({
  baseURL: API_BASE_URL,
});

export const sendRequestToGo = async () => {
  try {
    const response = await api.get('/go-endpoint'); // Update with your actual endpoint
    return response.data;
  } catch (error) {
    console.error('Error sending request to Go:', error);
    throw error;
  }
};

// Repeat similar steps for Rust and Python endpoints
