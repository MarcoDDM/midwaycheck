// app/javascript/packs/locations.js
document.addEventListener('DOMContentLoaded', function() {
  var form = document.getElementById('midway-form');
  var resultsList = document.getElementById('results-list');

  form.addEventListener('submit', function(event) {
    event.preventDefault();
    var formData = new FormData(form);

    fetch(form.action, {
      method: 'POST',
      body: formData
    })
    .then(function(response) {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.json();
    })
    .then(function(data) {
      displayResults(data.results);
    })
    .catch(function(error) {
      console.error('Error en la solicitud fetch:', error.message);
      alert('Hubo un error al procesar la solicitud. Inténtalo de nuevo más tarde.');
    });
  });

  function displayResults(results) {
    var resultsLimit = document.getElementById('results_limit').value;
    resultsList.innerHTML = '';

    switch (resultsLimit) {
      case 'best':
        var bestResult = findBestResult(results);
        appendResultItem(bestResult);
        break;
      case 'top5':
        var top5Results = results.slice(0, 5);
        top5Results.forEach(function(result) {
          appendResultItem(result);
        });
        break;
      case 'all':
        results.forEach(function(result) {
          appendResultItem(result);
        });
        break;
      default:
        console.error('Opción de límite de resultados no válida:', resultsLimit);
        break;
    }
  }

  function findBestResult(results) {
    // Implementa la lógica para encontrar el mejor resultado según tus criterios
    // Por ejemplo, podrías buscar el lugar con la mejor calificación (rating)
    return results.reduce(function(prev, current) {
      return (prev.rating > current.rating) ? prev : current;
    });
  }

  function appendResultItem(result) {
    var li = document.createElement('li');
    li.textContent = result.name; // Aquí puedes personalizar cómo se muestra cada resultado
    resultsList.appendChild(li);
  }
});
