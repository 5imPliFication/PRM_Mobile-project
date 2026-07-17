import React, { useState, useEffect, useRef } from 'react';
import { api } from '../utils/api';

export default function TeacherManager({ showToast }) {
  const [teachers, setTeachers] = useState([]);
  const [accounts, setAccounts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');

  // Modal states
  const [isEditMode, setIsEditMode] = useState(false);
  const [selectedTeacher, setSelectedTeacher] = useState(null);
  const [formData, setFormData] = useState({
    fullName: '',
    specialization: '',
    accountId: ''
  });

  const dialogRef = useRef(null);

  useEffect(() => {
    fetchTeachers();
    fetchAccounts();
  }, []);

  const fetchTeachers = async () => {
    setLoading(true);
    try {
      const data = await api.getTeachers();
      setTeachers(data);
    } catch (err) {
      showToast(err.message, 'error');
    } finally {
      setLoading(false);
    }
  };

  const fetchAccounts = async () => {
    try {
      const data = await api.getAccounts();
      setAccounts(data.filter(acc => acc.role === 'TEACHER'));
    } catch (err) {
      console.error(err);
    }
  };

  const handleOpenAddModal = () => {
    setIsEditMode(false);
    setSelectedTeacher(null);
    setFormData({
      fullName: '',
      specialization: '',
      accountId: ''
    });
    fetchAccounts();
    dialogRef.current?.showModal();
  };

  const handleOpenEditModal = (teacher) => {
    setIsEditMode(true);
    setSelectedTeacher(teacher);
    setFormData({
      fullName: teacher.fullName,
      specialization: teacher.specialization || '',
      accountId: teacher.accountId || ''
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
      if (isEditMode && selectedTeacher) {
        await api.updateTeacher(selectedTeacher.id, dataToSend);
        showToast('Cập nhật giáo viên thành công', 'success');
      } else {
        await api.createTeacher(dataToSend);
        showToast('Tạo giáo viên thành công', 'success');
      }
      handleCloseModal();
      fetchTeachers();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Bạn có chắc chắn muốn xóa giáo viên này? Tất cả các lịch giảng dạy và bài tập do giáo viên này tạo sẽ bị xóa.')) {
      return;
    }
    try {
      await api.deleteTeacher(id);
      showToast('Xóa giáo viên thành công', 'success');
      fetchTeachers();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const filteredTeachers = teachers.filter(t => {
    const term = searchTerm.toLowerCase();
    return t.fullName.toLowerCase().includes(term) || 
           (t.specialization && t.specialization.toLowerCase().includes(term));
  });

  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;

  useEffect(() => {
    setCurrentPage(1);
  }, [searchTerm]);

  const totalPages = Math.ceil(filteredTeachers.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const paginatedTeachers = filteredTeachers.slice(startIndex, startIndex + itemsPerPage);

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h2 style={{ fontSize: '1.5rem', marginBottom: '4px' }}>Quản lý giáo viên</h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Hồ sơ và chuyên môn giảng dạy của giáo viên</p>
        </div>
        <button className="btn btn-primary" onClick={handleOpenAddModal}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
          Thêm giáo viên
        </button>
      </div>

      <div className="glass-card" style={{ padding: '16px', marginBottom: '20px' }}>
        <input
          type="text"
          className="form-control"
          placeholder="Tìm theo tên giáo viên, chuyên môn..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px' }}>Đang tải dữ liệu giáo viên...</div>
      ) : (
        <>
          <div className="table-container">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Họ tên</th>
                  <th>Chuyên môn (Bộ môn)</th>
                  <th>Tài khoản liên kết</th>
                  <th style={{ textAlign: 'right' }}>Hành động</th>
                </tr>
              </thead>
              <tbody>
                {filteredTeachers.length === 0 ? (
                  <tr>
                    <td colSpan="4" style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '24px' }}>
                      Không tìm thấy giáo viên nào phù hợp
                    </td>
                  </tr>
                ) : (
                  paginatedTeachers.map(teacher => (
                    <tr key={teacher.id}>
                      <td style={{ fontWeight: '600' }}>{teacher.fullName}</td>
                      <td>
                        <span className="badge badge-teacher" style={{ fontSize: '0.85rem' }}>
                          {teacher.specialization || 'Chưa cập nhật'}
                        </span>
                      </td>
                      <td style={{ fontSize: '0.9rem' }}>
                        {teacher.accountPhone ? (
                          <span style={{ fontWeight: '500' }}>{teacher.accountPhone}</span>
                        ) : (
                          <span style={{ fontStyle: 'italic', color: 'var(--text-muted)' }}>Chưa liên kết</span>
                        )}
                      </td>
                      <td style={{ textAlign: 'right' }}>
                        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
                          <button className="btn btn-secondary btn-sm" onClick={() => handleOpenEditModal(teacher)}>
                            Sửa
                          </button>
                          <button className="btn btn-danger btn-sm" onClick={() => handleDelete(teacher.id)}>
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

          {totalPages > 1 && (
            <div style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              marginTop: '20px',
              padding: '12px 20px',
              background: 'rgba(18, 19, 26, 0.4)',
              border: '1px solid var(--border-color)',
              borderRadius: 'var(--radius-sm)',
              flexWrap: 'wrap',
              gap: '12px'
            }}>
              <div style={{ fontSize: '0.9rem', color: 'var(--text-secondary)' }}>
                Hiển thị {startIndex + 1} - {Math.min(startIndex + itemsPerPage, filteredTeachers.length)} trong tổng số {filteredTeachers.length} mục
              </div>
              <div style={{ display: 'flex', gap: '6px' }}>
                <button
                  className="btn btn-secondary btn-sm"
                  onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
                  disabled={currentPage === 1}
                  style={{ padding: '6px 12px', minWidth: '40px' }}
                >
                  Trước
                </button>
                {Array.from({ length: totalPages }, (_, i) => i + 1).map(page => (
                  <button
                    key={page}
                    className={`btn ${currentPage === page ? 'btn-primary' : 'btn-secondary'} btn-sm`}
                    onClick={() => setCurrentPage(page)}
                    style={{
                      padding: '6px 12px',
                      minWidth: '36px',
                      background: currentPage === page ? 'var(--color-accent-gradient)' : 'rgba(255, 255, 255, 0.04)',
                      borderColor: currentPage === page ? 'var(--color-accent)' : 'var(--border-color)'
                    }}
                  >
                    {page}
                  </button>
                ))}
                <button
                  className="btn btn-secondary btn-sm"
                  onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
                  disabled={currentPage === totalPages}
                  style={{ padding: '6px 12px', minWidth: '40px' }}
                >
                  Sau
                </button>
              </div>
            </div>
          )}
        </>
      )}

      {/* Add/Edit Modal */}
      <dialog ref={dialogRef}>
        <div className="modal-content">
          <div className="modal-header">
            <h3 className="modal-title">{isEditMode ? 'Cập nhật thông tin giáo viên' : 'Tạo mới hồ sơ giáo viên'}</h3>
            <button className="modal-close" onClick={handleCloseModal}>
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"></line>
                <line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
            </button>
          </div>
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label className="form-label">Họ và tên giáo viên *</label>
              <input
                type="text"
                className="form-control"
                required
                value={formData.fullName}
                onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
                placeholder="Ví dụ: Thầy Nguyễn Văn A"
              />
            </div>

            <div className="form-group">
              <label className="form-label">Chuyên môn (Môn giảng dạy)</label>
              <input
                type="text"
                className="form-control"
                value={formData.specialization}
                onChange={(e) => setFormData({ ...formData, specialization: e.target.value })}
                placeholder="Ví dụ: Toán học, Vật lý..."
              />
            </div>

            <div className="form-group">
              <label className="form-label">Tài khoản liên kết (Giáo viên)</label>
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
