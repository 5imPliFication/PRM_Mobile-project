import React, { useState, useEffect, useRef } from 'react';
import { api } from '../utils/api';

export default function ParentManager({ showToast }) {
  const [parents, setParents] = useState([]);
  const [students, setStudents] = useState([]);
  const [accounts, setAccounts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  
  // Managing children linkage state
  const [expandedParentId, setExpandedParentId] = useState(null);
  const [selectedStudentToLink, setSelectedStudentToLink] = useState('');

  // Modal states
  const [isEditMode, setIsEditMode] = useState(false);
  const [selectedParent, setSelectedParent] = useState(null);
  const [formData, setFormData] = useState({
    fullName: '',
    phone: '',
    occupation: '',
    relationship: 'Cha',
    accountId: ''
  });

  const dialogRef = useRef(null);

  useEffect(() => {
    fetchParents();
    fetchStudents();
    fetchAccounts();
  }, []);

  const fetchParents = async () => {
    setLoading(true);
    try {
      const data = await api.getParents();
      setParents(data);
    } catch (err) {
      showToast(err.message, 'error');
    } finally {
      setLoading(false);
    }
  };

  const fetchStudents = async () => {
    try {
      const data = await api.getStudents();
      setStudents(data);
    } catch (err) {
      console.error(err);
    }
  };

  const fetchAccounts = async () => {
    try {
      const data = await api.getAccounts();
      setAccounts(data.filter(acc => acc.role === 'PARENT'));
    } catch (err) {
      console.error(err);
    }
  };

  const handleOpenAddModal = () => {
    setIsEditMode(false);
    setSelectedParent(null);
    setFormData({
      fullName: '',
      phone: '',
      occupation: '',
      relationship: 'Cha',
      accountId: ''
    });
    fetchAccounts();
    dialogRef.current?.showModal();
  };

  const handleOpenEditModal = (parent) => {
    setIsEditMode(true);
    setSelectedParent(parent);
    setFormData({
      fullName: parent.fullName,
      phone: parent.phone || '',
      occupation: parent.occupation || '',
      relationship: parent.relationship || 'Cha',
      accountId: parent.accountId || ''
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
      if (isEditMode && selectedParent) {
        await api.updateParent(selectedParent.id, dataToSend);
        showToast('Cập nhật phụ huynh thành công', 'success');
      } else {
        await api.createParent(dataToSend);
        showToast('Tạo phụ huynh thành công', 'success');
      }
      handleCloseModal();
      fetchParents();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Bạn có chắc chắn muốn xóa phụ huynh này? Thao tác này sẽ gỡ liên kết học sinh và xóa thông tin phụ huynh.')) {
      return;
    }
    try {
      await api.deleteParent(id);
      showToast('Xóa phụ huynh thành công', 'success');
      fetchParents();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const handleLinkStudent = async (parentId) => {
    if (!selectedStudentToLink) {
      showToast('Vui lòng chọn một học sinh để liên kết', 'error');
      return;
    }
    try {
      await api.linkStudent(parentId, selectedStudentToLink);
      showToast('Liên kết học sinh thành công', 'success');
      setSelectedStudentToLink('');
      fetchParents();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const handleUnlinkStudent = async (parentId, studentId) => {
    if (!window.confirm('Bạn có chắc chắn muốn gỡ liên kết học sinh này khỏi phụ huynh?')) {
      return;
    }
    try {
      await api.unlinkStudent(parentId, studentId);
      showToast('Gỡ liên kết học sinh thành công', 'success');
      fetchParents();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const toggleExpandParent = (parentId) => {
    if (expandedParentId === parentId) {
      setExpandedParentId(null);
    } else {
      setExpandedParentId(parentId);
      setSelectedStudentToLink('');
    }
  };

  const filteredParents = parents.filter(p => {
    const term = searchTerm.toLowerCase();
    return p.fullName.toLowerCase().includes(term) ||
           (p.phone && p.phone.includes(term)) ||
           (p.relationship && p.relationship.toLowerCase().includes(term));
  });

  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;

  useEffect(() => {
    setCurrentPage(1);
  }, [searchTerm]);

  const totalPages = Math.ceil(filteredParents.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const paginatedParents = filteredParents.slice(startIndex, startIndex + itemsPerPage);

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h2 style={{ fontSize: '1.5rem', marginBottom: '4px' }}>Quản lý phụ huynh</h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Hồ sơ phụ huynh và liên kết con em (học sinh)</p>
        </div>
        <button className="btn btn-primary" onClick={handleOpenAddModal}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
          Thêm phụ huynh
        </button>
      </div>

      <div className="glass-card" style={{ padding: '16px', marginBottom: '20px' }}>
        <input
          type="text"
          className="form-control"
          placeholder="Tìm theo tên phụ huynh, số điện thoại, quan hệ..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px' }}>Đang tải dữ liệu phụ huynh...</div>
      ) : (
        <>
          <div className="table-container">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Họ tên</th>
                  <th>Quan hệ</th>
                  <th>Số điện thoại</th>
                  <th>Tài khoản liên kết</th>
                  <th>Số con em liên kết</th>
                  <th style={{ textAlign: 'right' }}>Hành động</th>
                </tr>
              </thead>
              <tbody>
                {filteredParents.length === 0 ? (
                  <tr>
                    <td colSpan="6" style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '24px' }}>
                      Không tìm thấy phụ huynh nào phù hợp
                    </td>
                  </tr>
                ) : (
                  paginatedParents.map(parent => {
                    const isExpanded = expandedParentId === parent.id;
                    return (
                      <React.Fragment key={parent.id}>
                        <tr>
                          <td style={{ fontWeight: '600' }}>{parent.fullName}</td>
                          <td>
                            <span className="badge badge-parent">
                              {parent.relationship || 'Chưa cập nhật'}
                            </span>
                          </td>
                          <td>{parent.phone || 'Chưa cập nhật'}</td>
                          <td style={{ fontSize: '0.9rem' }}>
                            {parent.accountPhone ? (
                              <span style={{ fontWeight: '500' }}>{parent.accountPhone}</span>
                            ) : (
                              <span style={{ fontStyle: 'italic', color: 'var(--text-muted)' }}>Chưa liên kết</span>
                            )}
                          </td>
                          <td>
                            <button 
                              className="btn btn-secondary btn-sm"
                              style={{ display: 'inline-flex', alignItems: 'center', gap: '6px' }}
                              onClick={() => toggleExpandParent(parent.id)}
                            >
                              {parent.studentIds ? parent.studentIds.length : 0} học sinh
                              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" style={{ transform: isExpanded ? 'rotate(180deg)' : 'none', transition: 'transform 0.2s' }}>
                                <path d="M6 9l6 6 6-6"/>
                              </svg>
                            </button>
                          </td>
                          <td style={{ textAlign: 'right' }}>
                            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
                              <button className="btn btn-secondary btn-sm" onClick={() => handleOpenEditModal(parent)}>
                                Sửa
                              </button>
                              <button className="btn btn-danger btn-sm" onClick={() => handleDelete(parent.id)}>
                                Xóa
                              </button>
                            </div>
                          </td>
                        </tr>
                        {isExpanded && (
                          <tr>
                            <td colSpan="6" style={{ background: 'rgba(255, 255, 255, 0.01)', padding: '20px 32px' }}>
                              <div style={{ borderLeft: '3px solid var(--color-accent)', paddingLeft: '16px' }}>
                                <h4 style={{ fontSize: '1rem', marginBottom: '12px' }}>Danh sách con em (Học sinh liên kết)</h4>
                                
                                {/* Current linked students */}
                                {(!parent.studentNames || parent.studentNames.length === 0) ? (
                                  <p style={{ fontStyle: 'italic', color: 'var(--text-secondary)', marginBottom: '16px', fontSize: '0.9rem' }}>
                                    Chưa liên kết với học sinh nào.
                                  </p>
                                ) : (
                                  <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap', marginBottom: '16px' }}>
                                    {parent.studentNames.map((name, idx) => (
                                      <div key={idx} style={{
                                        display: 'inline-flex',
                                        alignItems: 'center',
                                        gap: '8px',
                                        padding: '6px 12px',
                                        background: 'rgba(255, 255, 255, 0.04)',
                                        border: '1px solid var(--border-color)',
                                        borderRadius: '8px',
                                        fontSize: '0.9rem'
                                      }}>
                                        <span>{name}</span>
                                        <button 
                                          onClick={() => handleUnlinkStudent(parent.id, parent.studentIds[idx])}
                                          style={{ background: 'transparent', border: 'none', color: '#fca5a5', cursor: 'pointer', display: 'flex', alignItems: 'center' }}
                                          title="Gỡ liên kết"
                                        >
                                          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                            <line x1="18" y1="6" x2="6" y2="18"></line>
                                            <line x1="6" y1="6" x2="18" y2="18"></line>
                                          </svg>
                                        </button>
                                      </div>
                                    ))}
                                  </div>
                                )}

                                {/* Form to link a new student */}
                                <div style={{ display: 'flex', gap: '12px', maxWidth: '400px', alignItems: 'center' }}>
                                  <select 
                                    className="form-control form-select"
                                    value={selectedStudentToLink}
                                    onChange={(e) => setSelectedStudentToLink(e.target.value)}
                                    style={{ padding: '8px 12px', fontSize: '0.9rem' }}
                                  >
                                    <option value="">-- Chọn học sinh để liên kết --</option>
                                    {students.filter(s => !parent.studentIds?.includes(s.id)).map(student => (
                                      <option key={student.id} value={student.id}>
                                        {student.fullName} ({student.studentCode} - {student.className})
                                      </option>
                                    ))}
                                  </select>
                                  <button className="btn btn-primary btn-sm" onClick={() => handleLinkStudent(parent.id)}>
                                    Liên kết con em
                                  </button>
                                </div>
                              </div>
                            </td>
                          </tr>
                        )}
                      </React.Fragment>
                    );
                  })
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
                Hiển thị {startIndex + 1} - {Math.min(startIndex + itemsPerPage, filteredParents.length)} trong tổng số {filteredParents.length} mục
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
            <h3 className="modal-title">{isEditMode ? 'Cập nhật thông tin phụ huynh' : 'Tạo mới hồ sơ phụ huynh'}</h3>
            <button className="modal-close" onClick={handleCloseModal}>
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"></line>
                <line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
            </button>
          </div>
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label className="form-label">Họ và tên phụ huynh *</label>
              <input
                type="text"
                className="form-control"
                required
                value={formData.fullName}
                onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
                placeholder="Nhập họ và tên phụ huynh"
              />
            </div>

            <div className="form-group">
              <label className="form-label">Quan hệ với học sinh</label>
              <select
                className="form-control form-select"
                value={formData.relationship}
                onChange={(e) => setFormData({ ...formData, relationship: e.target.value })}
              >
                <option value="Cha">Cha</option>
                <option value="Mẹ">Mẹ</option>
                <option value="Người giám hộ">Người giám hộ khác</option>
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Số điện thoại liên lạc</label>
              <input
                type="text"
                className="form-control"
                value={formData.phone}
                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                placeholder="Nhập số điện thoại"
              />
            </div>

            <div className="form-group">
              <label className="form-label">Nghề nghiệp</label>
              <input
                type="text"
                className="form-control"
                value={formData.occupation}
                onChange={(e) => setFormData({ ...formData, occupation: e.target.value })}
                placeholder="Ví dụ: Kỹ sư, Giáo viên..."
              />
            </div>

            <div className="form-group">
              <label className="form-label">Tài khoản đăng nhập liên kết (Phụ huynh)</label>
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
