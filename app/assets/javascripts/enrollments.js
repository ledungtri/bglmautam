// Enrollment form JavaScript
// Using turbolinks:load event to ensure code runs on both page loads and Turbolinks navigations

document.addEventListener('turbolinks:load', function() {
  // Reset form visibility state
  var enrollmentForm = document.getElementById('enrollment-form');
  var showFormBtn = document.getElementById('enrollment-show-form-btn');

  if (enrollmentForm) {
    enrollmentForm.style.display = 'none';
  }

  if (showFormBtn) {
    showFormBtn.style.display = '';
  }

  // Setup show form button
  if (showFormBtn) {
    showFormBtn.addEventListener('click', function() {
      showFormBtn.style.display = 'none';
      if (enrollmentForm) {
        enrollmentForm.style.display = '';
      }
    });
  }

  // Setup year combobox change handler
  var yearCombobox = document.getElementById('enrollment-year-combobox');
  if (yearCombobox) {
    yearCombobox.addEventListener('change', function() {
      changeEnrollmentClassroom();
    });
  }
});

function changeEnrollmentClassroom() {
  var yearSelect = document.getElementById('enrollment-year-combobox');
  if (!yearSelect) return;

  var selectedYear = yearSelect.options[yearSelect.selectedIndex].value;
  var classroomSelect = document.getElementById('enrollment-classroom-select');
  if (!classroomSelect) return;

  // Get classroom data from data attributes
  var classroomData = JSON.parse(classroomSelect.dataset.classrooms || '{}');

  // Clear existing options
  classroomSelect.options.length = 0;

  // Add new options for selected year
  var classrooms = classroomData[selectedYear] || [];
  for (var i = 0; i < classrooms.length; i++) {
    var option = document.createElement('option');
    option.value = classrooms[i].id;
    option.text = classrooms[i].name;
    classroomSelect.appendChild(option);
  }
}