/**
 * API Integration for CV Portfolio
 * Fetches CV data from AWS API Gateway and displays view count
 */

// TODO: Replace with your actual API Gateway URL after infrastructure deployment
const API_URL = 'https://YOUR-API-ID.execute-api.us-east-1.amazonaws.com/prod/cv';
const CV_ID = 'portfolio1';

/**
 * Fetch CV data from API and update view counter
 */
async function fetchCVData() {
  const viewCounterElement = document.getElementById('view-counter');
  
  if (!viewCounterElement) {
    console.warn('View counter element not found');
    return;
  }

  try {
    // Show loading state
    viewCounterElement.innerHTML = '<p>⏳ Cargando datos...</p>';

    // Make API request
    const response = await fetch(`${API_URL}?id=${CV_ID}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Check if response is OK
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    // Parse JSON response
    const data = await response.json();

    // Display view count
    if (data && data.views !== undefined) {
      viewCounterElement.innerHTML = `
        <div class="view-counter-success">
          <h3>👁️ Visitas al Portfolio</h3>
          <p class="view-count">${data.views}</p>
          <p class="view-message">¡Gracias por visitar mi portfolio!</p>
        </div>
      `;
      
      console.log('CV Data loaded successfully:', data);
    } else {
      throw new Error('Invalid data format received from API');
    }

  } catch (error) {
    console.error('Error fetching CV data:', error);
    
    // Display error message
    viewCounterElement.innerHTML = `
      <div class="view-counter-error">
        <p>⚠️ No se pudo cargar el contador de visitas</p>
        <p class="error-details">${error.message}</p>
      </div>
    `;
  }
}

/**
 * Initialize API calls when DOM is ready
 */
document.addEventListener('DOMContentLoaded', () => {
  console.log('Initializing API integration...');
  fetchCVData();
});

/**
 * Optional: Refresh data periodically (every 5 minutes)
 */
// setInterval(fetchCVData, 5 * 60 * 1000);
