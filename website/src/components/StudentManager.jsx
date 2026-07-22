import React, { useState, useEffect, useRef } from 'react';
import { api } from '../utils/api';

export default function StudentManager({ showToast }) {
  const [students, setStudents] = useState([]);
  const [classList, setClassList] = useState([]);
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
    classId: '',
    academicYear: '2023 - 2026',
    campus: 'FPT School Cần Thơ',
    email: '',
    address: '',
    dateOfBirth: '',
    program: 'Phổ thông chất lượng cao',
    status: 'Đang học',
    accountId: ''
  });

  const dialogRef = useRef(null);

  useEffect(() => {
    fetchStudents();
    fetchClasses();
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

  const fetchClasses = async () => {
    try {
      const data = await api.getClasses();
      setClassList(data);
    } catch (err) {
      console.error(err);
    }
  };

  const fetchAccounts = async () => {
    try {
      const data = await api.getAccounts();
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
      classId: classList[0]?.id || '',
      academicYear: '2023 - 2026',
      campus: 'FPT School Cần Thơ',
      email: '',
      address: '',
      dateOfBirth: '',
      program: 'Phổ thông chất lượng cao',
      status: 'Đang học',
      accountId: ''
    });
    fetchClasses();
    fetchAccounts();
    dialogRef.current?.showModal();
  };

  const handleOpenEditModal = (student) => {
    setIsEditMode(true);
    setSelectedStudent(student);
    setFormData({
      studentCode: student.studentCode,
      fullName: student.fullName,
      classId: student.classId || '',
      academicYear: student.academicYear || '2023 - 2026',
      campus: student.campus || 'FPT School Cần Thơ',
      email: student.email || '',
      address: student.address || '',
      dateOfBirth: student.dateOfBirth || '',
      program: student.program || 'Phổ thông chất lượng cao',
      status: student.status || 'Đang học',
      accountId: student.accountId || ''
    });
    fetchClasses();
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
      classId: formData.classId === '' ? null : formData.classId,
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
    if (!window.confirm('Bạn có chắc chắn muốn xóa học sinh này? Tất cả bảng điểm, điểm danh của học sinh này sẽ bị xóa.')) {
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
  const uniqueClassNames = ['ALL', ...new Set(students.map(s => s.className).filter(Boolean))];

  const filteredStudents = students.filter(student => {
    const term = searchTerm.toLowerCase();
    const matchesSearch = student.fullName?.toLowerCase().includes(term) ||
                          student.studentCode?.toLowerCase().includes(term) ||
                          (student.className && student.className.toLowerCase().includes(term));
    const matchesFilter = filterClass === 'ALL' || student.className === filterClass;
    return matchesSearch && matchesFilter;
  });

  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;

  useEffect(() => {
    setCurrentPage(1);
  }, [searchTerm, filterClass]);

  const totalPages = Math.ceil(filteredStudents.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const paginatedStudents = filteredStudents.slice(startIndex, startIndex + itemsPerPage);

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
            {uniqueClassNames.filter(c => c !== 'ALL').map(c => (
              <option key={c} value={c}>{c}</option>
            ))}
          </select>
        </div>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px' }}>Đang tải dữ liệu học sinh...</div>
      ) : filteredStudents.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>Không có học sinh nào phù hợp</div>
      ) : (
        <>
          <div className="glass-card" style={{ padding: 0, overflow: 'hidden' }}>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Mã HS</th>
                  <th>Họ và tên</th>
                  <th>Lớp</th>
                  <th>GV Chủ nhiệm</th>
                  <th>Tài khoản</th>
                  <th>Trạng thái</th>
                  <th style={{ textAlign: 'right' }}>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                {paginatedStudents.map(student => (
                  <tr key={student.id}>
                    <td><span className="badge badge-student">{student.studentCode}</span></td>
                    <td style={{ fontWeight: '600' }}>{student.fullName}</td>
                    <td>{student.className || <span style={{ color: 'var(--text-muted)' }}>Chưa xếp lớp</span>}</td>
                    <td>{student.homeroomTeacher || <span style={{ color: 'var(--text-muted)' }}>--</span>}</td>
                    <td>
                      {student.accountPhone ? (
                        <span style={{ fontSize: '0.85rem', color: 'var(--color-accent)' }}>{student.accountPhone}</span>
                      ) : (
                        <span style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>Chưa liên kết</span>
                      )}
                    </td>
                    <td>
                      <span className={`badge ${student.status === 'Đang học' ? 'badge-active' : 'badge-inactive'}`}>
                        {student.status || 'Đang học'}
                      </span>
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                        <button className="btn btn-secondary" style={{ padding: '6px 12px', fontSize: '0.85rem' }} onClick={() => handleOpenEditModal(student)}>Sửa</button>
                        <button className="btn btn-secondary" style={{ padding: '6px 12px', fontSize: '0.85rem', color: '#fca5a5', borderColor: 'rgba(239, 68, 68, 0.2)' }} onClick={() => handleDelete(student.id)}>Xóa</button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          {totalPages > 1 && (
            <div style={{ display: 'flex', justifyContent: 'center', gap: '8px', marginTop: '20px' }}>
              <button className="btn btn-secondary" disabled={currentPage === 1} onClick={() => setCurrentPage(prev => prev - 1)}>Trước</button>
              <span style={{ display: 'flex', alignItems: 'center', padding: '0 12px', fontSize: '0.9rem' }}>Trang {currentPage} / {totalPages}</span>
              <button className="btn btn-secondary" disabled={currentPage === totalPages} onClick={() => setCurrentPage(prev => prev + 1)}>Sau</button>
            </div>
          )}
        </>
      )}

      {/* Modal Dialog for Add/Edit Student */}
      <dialog ref={dialogRef} className="modal">
        <div style={{ width: '100%', maxWidth: '600px' }} className="modal-content">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <h3 style={{ fontSize: '1.25rem', fontWeight: '700' }}>
              {isEditMode ? 'Cập nhật thông tin học sinh' : 'Thêm học sinh mới'}
            </h3>
            <button onClick={handleCloseModal} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontSize: '1.2rem' }}>✕</button>
          </div>

          <form onSubmit={handleSubmit}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div className="form-group">
                <label className="form-label">Mã học sinh *</label>
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
                  placeholder="Ví dụ: Nguyễn Văn A"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Lớp học *</label>
                <select
                  className="form-control form-select"
                  required
                  value={formData.classId}
                  onChange={(e) => setFormData({ ...formData, classId: e.target.value })}
                >
                  <option value="">-- Chọn lớp học --</option>
                  {classList.map(c => (
                    <option key={c.id} value={c.id}>
                      {c.name} {c.homeroomTeacherName ? `(GVCN: ${c.homeroomTeacherName})` : ''}
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Niên khóa</label>
                <input
                  type="text"
                  className="form-control"
                  value={formData.academicYear}
                  onChange={(e) => setFormData({ ...formData, academicYear: e.target.value })}
                  placeholder="2023 - 2026"
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
                  placeholder="Nhập địa chỉ"
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

              <div className="form-group" style={{ gridColumn: 'span 2' }}>
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
            </div>

            <div className="modal-footer" style={{ marginTop: '20px' }}>
              <button type="button" className="btn btn-secondary" onClick={handleCloseModal}>Hủy</button>
              <button type="submit" className="btn btn-primary">{isEditMode ? 'Cập nhật' : 'Tạo mới'}</button>
            </div>
          </form>
        </div>
      </dialog>
    </div>
  );
}
