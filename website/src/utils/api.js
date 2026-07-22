const BASE_URL = '/api';

async function request(endpoint, options = {}) {
  const token = localStorage.getItem('jwt_token');
  
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const config = {
    ...options,
    headers,
  };

  if (config.body && typeof config.body === 'object') {
    config.body = JSON.stringify(config.body);
  }

  const response = await fetch(`${BASE_URL}${endpoint}`, config);
  const data = await response.json();

  if (!response.ok || !data.success) {
    throw new Error(data.message || 'Đã xảy ra lỗi hệ thống');
  }

  return data.data;
}

export const api = {
  login: (phone, password) => 
    request('/auth/login', {
      method: 'POST',
      body: { phone, password }
    }),
    
  getStats: () => request('/admin/stats'),
  
  // Accounts
  getAccounts: () => request('/admin/accounts'),
  createAccount: (data) => request('/admin/accounts', { method: 'POST', body: data }),
  updateAccount: (id, data) => request(`/admin/accounts/${id}`, { method: 'PUT', body: data }),
  deleteAccount: (id) => request(`/admin/accounts/${id}`, { method: 'DELETE' }),

  // Classes
  getClasses: () => request('/admin/classes'),
  createClass: (data) => request('/admin/classes', { method: 'POST', body: data }),
  updateClass: (id, data) => request(`/admin/classes/${id}`, { method: 'PUT', body: data }),
  deleteClass: (id) => request(`/admin/classes/${id}`, { method: 'DELETE' }),

  // Students
  getStudents: () => request('/admin/students'),
  createStudent: (data) => request('/admin/students', { method: 'POST', body: data }),
  updateStudent: (id, data) => request(`/admin/students/${id}`, { method: 'PUT', body: data }),
  deleteStudent: (id) => request(`/admin/students/${id}`, { method: 'DELETE' }),

  // Teachers
  getTeachers: () => request('/admin/teachers'),
  createTeacher: (data) => request('/admin/teachers', { method: 'POST', body: data }),
  updateTeacher: (id, data) => request(`/admin/teachers/${id}`, { method: 'PUT', body: data }),
  deleteTeacher: (id) => request(`/admin/teachers/${id}`, { method: 'DELETE' }),

  // Parents
  getParents: () => request('/admin/parents'),
  createParent: (data) => request('/admin/parents', { method: 'POST', body: data }),
  updateParent: (id, data) => request(`/admin/parents/${id}`, { method: 'PUT', body: data }),
  deleteParent: (id) => request(`/admin/parents/${id}`, { method: 'DELETE' }),
  linkStudent: (parentId, studentId) => request(`/admin/parents/${parentId}/students/${studentId}`, { method: 'POST' }),
  unlinkStudent: (parentId, studentId) => request(`/admin/parents/${parentId}/students/${studentId}`, { method: 'DELETE' }),

  // Subjects
  getSubjects: () => request('/admin/subjects'),
  createSubject: (data) => request('/admin/subjects', { method: 'POST', body: data }),
  updateSubject: (id, data) => request(`/admin/subjects/${id}`, { method: 'PUT', body: data }),
  deleteSubject: (id) => request(`/admin/subjects/${id}`, { method: 'DELETE' }),

  // Schedules
  getSchedules: () => request('/admin/schedules'),
  createSchedule: (data) => request('/admin/schedules', { method: 'POST', body: data }),
  updateSchedule: (id, data) => request(`/admin/schedules/${id}`, { method: 'PUT', body: data }),
  deleteSchedule: (id) => request(`/admin/schedules/${id}`, { method: 'DELETE' }),

  // Notifications
  getAdminNotifications: () => request('/admin/notifications'),
  sendNotification: (data) => request('/admin/notifications', { method: 'POST', body: data }),
  deleteAdminNotification: (id) => request(`/admin/notifications/${id}`, { method: 'DELETE' }),
};
