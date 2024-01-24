# Create utils/api.js file
cat <<'EOF' > client_service/utils/api.js
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
EOF

# Create client_service/pages/index.js file
cat <<'EOF' > client_service/pages/index.js
// pages/index.js
import React from 'react';
import { useQuery } from 'react-query';
import { sendRequestToGo } from '../utils/api';

const HomePage = () => {
  const { data, error, isLoading } = useQuery('goData', sendRequestToGo);

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error loading data</div>;
  }

  return (
    <div>
      <h1>Data from Go Service</h1>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
};

export default HomePage;
EOF
