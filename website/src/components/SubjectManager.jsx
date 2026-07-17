import React, { useState, useEffect, useRef } from 'react';
import { api } from '../utils/api';

export default function SubjectManager({ showToast }) {
  const [subjects, setSubjects] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');

  // Modal states
  const [isEditMode, setIsEditMode] = useState(false);
  const [selectedSubject, setSelectedSubject] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    code: ''
  });

  const dialogRef = useRef(null);

  useEffect(() => {
    fetchSubjects();
  }, []);

  const fetchSubjects = async () => {
    setLoading(true);
    try {
      const data = await api.getSubjects();
      setSubjects(data);
    } catch (err) {
      showToast(err.message, 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleOpenAddModal = () => {
    setIsEditMode(false);
    setSelectedSubject(null);
    setFormData({
      name: '',
      code: ''
    });
    dialogRef.current?.showModal();
  };

  const handleOpenEditModal = (subject) => {
    setIsEditMode(true);
    setSelectedSubject(subject);
    setFormData({
      name: subject.name,
      code: subject.code
    });
    dialogRef.current?.showModal();
  };

  const handleCloseModal = () => {
    dialogRef.current?.close();
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (isEditMode && selectedSubject) {
        await api.updateSubject(selectedSubject.id, formData);
        showToast('Cập nhật môn học thành công', 'success');
      } else {
        await api.createSubject(formData);
        showToast('Tạo môn học thành công', 'success');
      }
      handleCloseModal();
      fetchSubjects();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Bạn có chắc chắn muốn xóa môn học này? Tất cả các lịch học và bài tập của môn học này sẽ bị xóa khỏi hệ thống.')) {
      return;
    }
    try {
      await api.deleteSubject(id);
      showToast('Xóa môn học thành công', 'success');
      fetchSubjects();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const filteredSubjects = subjects.filter(s => {
    const term = searchTerm.toLowerCase();
    return s.name.toLowerCase().includes(term) || s.code.toLowerCase().includes(term);
  });

  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;

  useEffect(() => {
    setCurrentPage(1);
  }, [searchTerm]);

  const totalPages = Math.ceil(filteredSubjects.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const paginatedSubjects = filteredSubjects.slice(startIndex, startIndex + itemsPerPage);

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h2 style={{ fontSize: '1.5rem', marginBottom: '4px' }}>Quản lý môn học</h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Chương trình môn học của trường</p>
        </div>
        <button className="btn btn-primary" onClick={handleOpenAddModal}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
          Thêm môn học
        </button>
      </div>

      <div className="glass-card" style={{ padding: '16px', marginBottom: '20px' }}>
        <input
          type="text"
          className="form-control"
          placeholder="Tìm theo tên môn học, mã môn học..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px' }}>Đang tải dữ liệu môn học...</div>
      ) : (
        <>
          <div className="table-container" style={{ maxWidth: '800px' }}>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Mã môn học</th>
                  <th>Tên môn học</th>
                  <th style={{ textAlign: 'right' }}>Hành động</th>
                </tr>
              </thead>
              <tbody>
                {filteredSubjects.length === 0 ? (
                  <tr>
                    <td colSpan="3" style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '24px' }}>
                      Không tìm thấy môn học nào phù hợp
                    </td>
                  </tr>
                ) : (
                  paginatedSubjects.map(sub => (
                    <tr key={sub.id}>
                      <td style={{ fontWeight: '600', color: 'var(--color-accent)' }}>{sub.code}</td>
                      <td style={{ fontWeight: '500' }}>{sub.name}</td>
                      <td style={{ textAlign: 'right' }}>
                        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
                          <button className="btn btn-secondary btn-sm" onClick={() => handleOpenEditModal(sub)}>
                            Sửa
                          </button>
                          <button className="btn btn-danger btn-sm" onClick={() => handleDelete(sub.id)}>
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
              gap: '12px',
              maxWidth: '800px'
            }}>
              <div style={{ fontSize: '0.9rem', color: 'var(--text-secondary)' }}>
                Hiển thị {startIndex + 1} - {Math.min(startIndex + itemsPerPage, filteredSubjects.length)} trong tổng số {filteredSubjects.length} mục
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
            <h3 className="modal-title">{isEditMode ? 'Cập nhật thông tin môn học' : 'Tạo mới môn học'}</h3>
            <button className="modal-close" onClick={handleCloseModal}>
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"></line>
                <line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
            </button>
          </div>
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label className="form-label">Mã môn học *</label>
              <input
                type="text"
                className="form-control"
                required
                value={formData.code}
                onChange={(e) => setFormData({ ...formData, code: e.target.value })}
                placeholder="Ví dụ: MATH11, PHYS11..."
              />
            </div>

            <div className="form-group">
              <label className="form-label">Tên môn học *</label>
              <input
                type="text"
                className="form-control"
                required
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                placeholder="Nhập tên môn học"
              />
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
