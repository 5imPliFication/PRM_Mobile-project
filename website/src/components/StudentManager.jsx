import React, { useState, useEffect, useRef } from 'react';
import { api } from '../utils/api';

export default function StudentManager({ showToast }) {
  const [students, setStudents] = useState([]);
  const [accounts, setAccounts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterClass, setFilterClass] = useState('ALL');

  // Modal states
  const [isEditMode, setIsEditMode] = useState(false);
  const [selectedStudent, setSelectedStudent] = useState(null);
  const [formData, setFormData] = useState({
    studentCode: '',
    fullName: '',
    className: '',
    academicYear: '2023 - 2026',
    campus: 'FPT School Cần Thơ',
    email: '',
    address: '',
    dateOfBirth: '',
    program: 'Phổ thông chất lượng cao',
    status: 'Đang học',
    homeroomTeacher: '',
    accountId: ''
  });

  const dialogRef = useRef(null);

  useEffect(() => {
    fetchStudents();
    fetchAccounts();
  }, []);

  const fetchStudents = async () => {
    setLoading(true);
    try {
      const data = await api.getStudents();
      setStudents(data);
    } catch (err) {
      showToast(err.message, 'error');
    } finally {
      setLoading(false);
    }
  };

  const fetchAccounts = async () => {
    try {
      const data = await api.getAccounts();
      // Only accounts with role STUDENT that are either not linked or linked to this student
      setAccounts(data.filter(acc => acc.role === 'STUDENT'));
    } catch (err) {
      console.error(err);
    }
  };

  const handleOpenAddModal = () => {
    setIsEditMode(false);
    setSelectedStudent(null);
    setFormData({
      studentCode: '',
      fullName: '',
      className: '',
      academicYear: '2023 - 2026',
      campus: 'FPT School Cần Thơ',
      email: '',
      address: '',
      dateOfBirth: '',
      program: 'Phổ thông chất lượng cao',
      status: 'Đang học',
      homeroomTeacher: '',
      accountId: ''
    });
    fetchAccounts();
    dialogRef.current?.showModal();
  };

  const handleOpenEditModal = (student) => {
    setIsEditMode(true);
    setSelectedStudent(student);
    setFormData({
      studentCode: student.studentCode,
      fullName: student.fullName,
      className: student.className,
      academicYear: student.academicYear || '2023 - 2026',
      campus: student.campus || 'FPT School Cần Thơ',
      email: student.email || '',
      address: student.address || '',
      dateOfBirth: student.dateOfBirth || '',
      program: student.program || 'Phổ thông chất lượng cao',
      status: student.status || 'Đang học',
      homeroomTeacher: student.homeroomTeacher || '',
      accountId: student.accountId || ''
    });
    fetchAccounts();
    dialogRef.current?.showModal();
  };

  const handleCloseModal = () => {
    dialogRef.current?.close();
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const dataToSend = {
      ...formData,
      accountId: formData.accountId === '' ? null : formData.accountId
    };

    try {
      if (isEditMode && selectedStudent) {
        await api.updateStudent(selectedStudent.id, dataToSend);
        showToast('Cập nhật học sinh thành công', 'success');
      } else {
        await api.createStudent(dataToSend);
        showToast('Tạo học sinh thành công', 'success');
      }
      handleCloseModal();
      fetchStudents();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Bạn có chắc chắn muốn xóa học sinh này? Tất cả bảng điểm, điểm danh, lịch học của học sinh này sẽ bị xóa.')) {
      return;
    }
    try {
      await api.deleteStudent(id);
      showToast('Xóa học sinh thành công', 'success');
      fetchStudents();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  // Get unique class names for filters
  const classesList = ['ALL', ...new Set(students.map(s => s.className).filter(Boolean))];

  const filteredStudents = students.filter(student => {
    const term = searchTerm.toLowerCase();
    const matchesSearch = student.fullName.toLowerCase().includes(term) ||
                          student.studentCode.toLowerCase().includes(term) ||
                          student.className.toLowerCase().includes(term);
    const matchesFilter = filterClass === 'ALL' || student.className === filterClass;
    return matchesSearch && matchesFilter;
  });

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h2 style={{ fontSize: '1.5rem', marginBottom: '4px' }}>Quản lý học sinh</h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Hồ sơ chi tiết, phân lớp học sinh</p>
        </div>
        <button className="btn btn-primary" onClick={handleOpenAddModal}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
          Thêm học sinh
        </button>
      </div>

      {/* Search and Filters */}
      <div className="glass-card" style={{ padding: '16px', display: 'flex', gap: '16px', marginBottom: '20px', flexWrap: 'wrap' }}>
        <div style={{ flex: '1', minWidth: '200px' }}>
          <input
            type="text"
            className="form-control"
            placeholder="Tìm theo tên, MSSV, lớp học..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <div style={{ width: '180px' }}>
          <select className="form-control form-select" value={filterClass} onChange={(e) => setFilterClass(e.target.value)}>
            <option value="ALL">Tất cả các lớp</option>
            {classesList.filter(c => c !== 'ALL').map(c => (
              <option key={c} value={c}>{c}</option>
            ))}
          </select>
        </div>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px' }}>Đang tải dữ liệu học sinh...</div>
      ) : (
        <div className="table-container">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Mã học sinh</th>
                <th>Họ tên</th>
                <th>Lớp</th>
                <th>Điện thoại liên kết</th>
                <th>Giáo viên chủ nhiệm</th>
                <th>Trạng thái</th>
                <th style={{ textAlign: 'right' }}>Hành động</th>
              </tr>
            </thead>
            <tbody>
              {filteredStudents.length === 0 ? (
                <tr>
                  <td colSpan="7" style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '24px' }}>
                    Không tìm thấy học sinh nào phù hợp
                  </td>
                </tr>
              ) : (
                filteredStudents.map(student => (
                  <tr key={student.id}>
                    <td style={{ fontWeight: '600', color: 'var(--color-accent)' }}>{student.studentCode}</td>
                    <td style={{ fontWeight: '500' }}>{student.fullName}</td>
                    <td>{student.className}</td>
                    <td style={{ fontSize: '0.9rem' }}>
                      {student.accountPhone ? (
                        <span style={{ fontWeight: '500' }}>{student.accountPhone}</span>
                      ) : (
                        <span style={{ fontStyle: 'italic', color: 'var(--text-muted)' }}>Chưa liên kết</span>
                      )}
                    </td>
                    <td style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>{student.homeroomTeacher || 'Chưa phân công'}</td>
                    <td>
                      <span className={`badge ${student.status === 'Đang học' ? 'badge-student' : 'badge-inactive'}`}>
                        {student.status}
                      </span>
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
                        <button className="btn btn-secondary btn-sm" onClick={() => handleOpenEditModal(student)}>
                          Sửa
                        </button>
                        <button className="btn btn-danger btn-sm" onClick={() => handleDelete(student.id)}>
                          Xóa
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* Add/Edit Modal */}
      <dialog ref={dialogRef}>
        <div className="modal-content" style={{ maxWidth: '650px' }}>
          <div className="modal-header">
            <h3 className="modal-title">{isEditMode ? 'Cập nhật thông tin học sinh' : 'Tạo mới hồ sơ học sinh'}</h3>
            <button className="modal-close" onClick={handleCloseModal}>
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"></line>
                <line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
            </button>
          </div>
          <form onSubmit={handleSubmit}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div className="form-group">
                <label className="form-label">Mã số học sinh *</label>
                <input
                  type="text"
                  className="form-control"
                  required
                  value={formData.studentCode}
                  onChange={(e) => setFormData({ ...formData, studentCode: e.target.value })}
                  placeholder="Ví dụ: FPT08925"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Họ và tên *</label>
                <input
                  type="text"
                  className="form-control"
                  required
                  value={formData.fullName}
                  onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
                  placeholder="Nhập họ và tên học sinh"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Lớp *</label>
                <input
                  type="text"
                  className="form-control"
                  required
                  value={formData.className}
                  onChange={(e) => setFormData({ ...formData, className: e.target.value })}
                  placeholder="Ví dụ: 11A1"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Niên khóa</label>
                <input
                  type="text"
                  className="form-control"
                  value={formData.academicYear}
                  onChange={(e) => setFormData({ ...formData, academicYear: e.target.value })}
                  placeholder="Ví dụ: 2023 - 2026"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Cơ sở (Campus)</label>
                <input
                  type="text"
                  className="form-control"
                  value={formData.campus}
                  onChange={(e) => setFormData({ ...formData, campus: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label className="form-label">Email học sinh</label>
                <input
                  type="email"
                  className="form-control"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  placeholder="email@fpt.edu.vn"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Địa chỉ</label>
                <input
                  type="text"
                  className="form-control"
                  value={formData.address}
                  onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                  placeholder="Nhập địa chỉ tạm trú/thường trú"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Ngày sinh</label>
                <input
                  type="date"
                  className="form-control"
                  value={formData.dateOfBirth}
                  onChange={(e) => setFormData({ ...formData, dateOfBirth: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label className="form-label">Hệ đào tạo</label>
                <input
                  type="text"
                  className="form-control"
                  value={formData.program}
                  onChange={(e) => setFormData({ ...formData, program: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label className="form-label">Giáo viên chủ nhiệm</label>
                <input
                  type="text"
                  className="form-control"
                  value={formData.homeroomTeacher}
                  onChange={(e) => setFormData({ ...formData, homeroomTeacher: e.target.value })}
                  placeholder="Nhập tên giáo viên chủ nhiệm"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Tài khoản liên kết (Học sinh)</label>
                <select
                  className="form-control form-select"
                  value={formData.accountId}
                  onChange={(e) => setFormData({ ...formData, accountId: e.target.value })}
                >
                  <option value="">-- Chưa liên kết tài khoản --</option>
                  {accounts.map(acc => (
                    <option key={acc.id} value={acc.id}>
                      {acc.phone} {acc.linkedName ? `(Đã liên kết với ${acc.linkedName})` : ''}
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Trạng thái học tập</label>
                <select
                  className="form-control form-select"
                  value={formData.status}
                  onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                >
                  <option value="Đang học">Đang học</option>
                  <option value="Bảo lưu">Bảo lưu</option>
                  <option value="Đã tốt nghiệp">Đã tốt nghiệp</option>
                  <option value="Đã thôi học">Đã thôi học</option>
                </select>
              </div>
            </div>

            <div className="modal-footer">
              <button type="button" className="btn btn-secondary" onClick={handleCloseModal}>Hủy</button>
              <button type="submit" className="btn btn-primary">{isEditMode ? 'Cập nhật' : 'Tạo mới'}</button>
            </div>
          </form>
        </div>
      </dialog>
    </div>
  );
}
