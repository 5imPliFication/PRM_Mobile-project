import React, { useState, useEffect, useRef } from 'react';
import { api } from '../utils/api';

export default function ClassManager({ showToast }) {
  const [classes, setClasses] = useState([]);
  const [teachers, setTeachers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');

  // Modal states
  const [isEditMode, setIsEditMode] = useState(false);
  const [selectedClass, setSelectedClass] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    gradeLevel: 11,
    academicYear: '2023 - 2026',
    campus: 'FPT School Cần Thơ',
    homeroomTeacherId: ''
  });

  const dialogRef = useRef(null);

  useEffect(() => {
    fetchClasses();
    fetchTeachers();
  }, []);

  const fetchClasses = async () => {
    setLoading(true);
    try {
      const data = await api.getClasses();
      setClasses(data);
    } catch (err) {
      showToast(err.message, 'error');
    } finally {
      setLoading(false);
    }
  };

  const fetchTeachers = async () => {
    try {
      const data = await api.getTeachers();
      setTeachers(data);
    } catch (err) {
      console.error(err);
    }
  };

  const handleOpenAddModal = () => {
    setIsEditMode(false);
    setSelectedClass(null);
    setFormData({
      name: '',
      gradeLevel: 11,
      academicYear: '2023 - 2026',
      campus: 'FPT School Cần Thơ',
      homeroomTeacherId: ''
    });
    fetchTeachers();
    dialogRef.current?.showModal();
  };

  const handleOpenEditModal = (c) => {
    setIsEditMode(true);
    setSelectedClass(c);
    setFormData({
      name: c.name,
      gradeLevel: c.gradeLevel || 11,
      academicYear: c.academicYear || '2023 - 2026',
      campus: c.campus || 'FPT School Cần Thơ',
      homeroomTeacherId: c.homeroomTeacherId || ''
    });
    fetchTeachers();
    dialogRef.current?.showModal();
  };

  const handleCloseModal = () => {
    dialogRef.current?.close();
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const dataToSend = {
      ...formData,
      gradeLevel: formData.gradeLevel ? parseInt(formData.gradeLevel, 10) : null,
      homeroomTeacherId: formData.homeroomTeacherId === '' ? null : formData.homeroomTeacherId
    };

    try {
      if (isEditMode && selectedClass) {
        await api.updateClass(selectedClass.id, dataToSend);
        showToast('Cập nhật lớp học thành công', 'success');
      } else {
        await api.createClass(dataToSend);
        showToast('Tạo lớp học thành công', 'success');
      }
      handleCloseModal();
      fetchClasses();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Bạn có chắc chắn muốn xóa lớp học này? Lịch học của lớp sẽ bị xóa.')) {
      return;
    }
    try {
      await api.deleteClass(id);
      showToast('Xóa lớp học thành công', 'success');
      fetchClasses();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const filteredClasses = classes.filter(c => {
    const term = searchTerm.toLowerCase();
    return (
      c.name?.toLowerCase().includes(term) ||
      (c.homeroomTeacherName && c.homeroomTeacherName.toLowerCase().includes(term)) ||
      (c.campus && c.campus.toLowerCase().includes(term))
    );
  });

  return (
    <div>
      {/* Header section */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h2 style={{ fontSize: '1.5rem', fontWeight: '700', marginBottom: '4px' }}>Quản lý Lớp học</h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Quản lý thông tin lớp, phân công GVCN & sĩ số học sinh</p>
        </div>
        <button className="btn btn-primary" onClick={handleOpenAddModal}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
          Thêm lớp học mới
        </button>
      </div>

      {/* Filter and Search Bar */}
      <div className="glass-card" style={{ marginBottom: '24px', padding: '16px' }}>
        <div style={{ display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
          <div style={{ flex: 1, minWidth: '240px' }}>
            <input
              type="text"
              className="form-control"
              placeholder="Tìm kiếm tên lớp, GVCN, cơ sở..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
        </div>
      </div>

      {/* Table section */}
      <div className="glass-card" style={{ padding: 0, overflow: 'hidden' }}>
        {loading ? (
          <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>Đang tải danh sách lớp học...</div>
        ) : filteredClasses.length === 0 ? (
          <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>Không tìm thấy lớp học nào</div>
        ) : (
          <table className="admin-table">
            <thead>
              <tr>
                <th>Tên lớp</th>
                <th>Khối</th>
                <th>Niên khóa</th>
                <th>Cơ sở</th>
                <th>Giáo viên chủ nhiệm</th>
                <th>Sĩ số</th>
                <th style={{ textAlign: 'right' }}>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {filteredClasses.map((c) => (
                <tr key={c.id}>
                  <td>
                    <div style={{ fontWeight: '600', color: 'var(--color-accent)' }}>{c.name}</div>
                  </td>
                  <td>Khối {c.gradeLevel || '--'}</td>
                  <td>{c.academicYear || '--'}</td>
                  <td>{c.campus || '--'}</td>
                  <td>
                    {c.homeroomTeacherName ? (
                      <span className="badge badge-teacher" style={{ fontWeight: '500' }}>
                        {c.homeroomTeacherName}
                      </span>
                    ) : (
                      <span style={{ color: 'var(--text-muted)', fontSize: '0.85rem' }}>Chưa phân công</span>
                    )}
                  </td>
                  <td>
                    <span className="badge" style={{ background: 'rgba(16, 185, 129, 0.1)', color: 'var(--color-success)' }}>
                      {c.studentCount || 0} học sinh
                    </span>
                  </td>
                  <td style={{ textAlign: 'right' }}>
                    <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                      <button className="btn btn-secondary" style={{ padding: '6px 12px', fontSize: '0.85rem' }} onClick={() => handleOpenEditModal(c)}>
                        Sửa
                      </button>
                      <button className="btn btn-secondary" style={{ padding: '6px 12px', fontSize: '0.85rem', color: '#fca5a5', borderColor: 'rgba(239, 68, 68, 0.2)' }} onClick={() => handleDelete(c.id)}>
                        Xóa
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Modal Dialog for Add/Edit Class */}
      <dialog ref={dialogRef} className="modal">
        <div style={{ width: '100%', maxWidth: '500px' }} className="modal-content">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <h3 style={{ fontSize: '1.25rem', fontWeight: '700' }}>
              {isEditMode ? 'Cập nhật Lớp học' : 'Thêm Lớp học mới'}
            </h3>
            <button
              onClick={handleCloseModal}
              style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontSize: '1.2rem' }}
            >
              ✕
            </button>
          </div>

          <form onSubmit={handleSubmit}>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div className="form-group">
                <label className="form-label">Tên lớp học *</label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="Ví dụ: 11A1"
                  required
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div className="form-group">
                  <label className="form-label">Khối lớp</label>
                  <select
                    className="form-control"
                    value={formData.gradeLevel}
                    onChange={(e) => setFormData({ ...formData, gradeLevel: e.target.value })}
                  >
                    <option value={10}>Khối 10</option>
                    <option value={11}>Khối 11</option>
                    <option value={12}>Khối 12</option>
                  </select>
                </div>

                <div className="form-group">
                  <label className="form-label">Niên khóa</label>
                  <input
                    type="text"
                    className="form-control"
                    placeholder="2023 - 2026"
                    value={formData.academicYear}
                    onChange={(e) => setFormData({ ...formData, academicYear: e.target.value })}
                  />
                </div>
              </div>

              <div className="form-group">
                <label className="form-label">Cơ sở trường</label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="FPT School Cần Thơ"
                  value={formData.campus}
                  onChange={(e) => setFormData({ ...formData, campus: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label className="form-label">Giáo viên chủ nhiệm</label>
                <select
                  className="form-control"
                  value={formData.homeroomTeacherId}
                  onChange={(e) => setFormData({ ...formData, homeroomTeacherId: e.target.value })}
                >
                  <option value="">-- Chưa phân công --</option>
                  {teachers.map((t) => (
                    <option key={t.id} value={t.id}>
                      {t.fullName} ({t.specialization || 'Chưa rõ chuyên môn'}) {t.homeroomClass ? `[Đang CN ${t.homeroomClass}]` : ''}
                    </option>
                  ))}
                </select>
              </div>

              <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end', marginTop: '12px' }}>
                <button type="button" className="btn btn-secondary" onClick={handleCloseModal}>
                  Hủy
                </button>
                <button type="submit" className="btn btn-primary">
                  {isEditMode ? 'Lưu thay đổi' : 'Tạo lớp học'}
                </button>
              </div>
            </div>
          </form>
        </div>
      </dialog>
    </div>
  );
}
