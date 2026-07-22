import React, { useState, useEffect, useRef } from 'react';
import { api } from '../utils/api';

const DAYS_OF_WEEK = {
  2: 'Thứ Hai',
  3: 'Thứ Ba',
  4: 'Thứ Tư',
  5: 'Thứ Năm',
  6: 'Thứ Sáu',
  7: 'Thứ Bảy',
  8: 'Chủ Nhật'
};

export default function ScheduleManager({ showToast }) {
  const [schedules, setSchedules] = useState([]);
  const [subjects, setSubjects] = useState([]);
  const [teachers, setTeachers] = useState([]);
  const [classes, setClasses] = useState([]);
  
  const [loading, setLoading] = useState(false);
  const [filterDay, setFilterDay] = useState('ALL');
  const [searchTerm, setSearchTerm] = useState('');

  // Modal states
  const [isEditMode, setIsEditMode] = useState(false);
  const [selectedSchedule, setSelectedSchedule] = useState(null);
  const [formData, setFormData] = useState({
    dayOfWeek: 2,
    startTime: '07:30',
    endTime: '09:00',
    room: '',
    status: 'Sắp học',
    subjectId: '',
    teacherId: '',
    classId: ''
  });

  const dialogRef = useRef(null);

  useEffect(() => {
    fetchSchedules();
    fetchDropdowns();
  }, []);

  const fetchSchedules = async () => {
    setLoading(true);
    try {
      const data = await api.getSchedules();
      setSchedules(data);
    } catch (err) {
      showToast(err.message, 'error');
    } finally {
      setLoading(false);
    }
  };

  const fetchDropdowns = async () => {
    try {
      const subs = await api.getSubjects();
      setSubjects(subs);
      
      const tc = await api.getTeachers();
      setTeachers(tc);

      const cl = await api.getClasses();
      setClasses(cl);
    } catch (err) {
      console.error('Failed to load dropdowns', err);
    }
  };

  const handleOpenAddModal = () => {
    setIsEditMode(false);
    setSelectedSchedule(null);
    setFormData({
      dayOfWeek: 2,
      startTime: '07:30',
      endTime: '08:15',
      room: '',
      status: 'Sắp học',
      subjectId: subjects[0]?.id || '',
      teacherId: teachers[0]?.id || '',
      classId: classes[0]?.id || ''
    });
    dialogRef.current?.showModal();
  };

  const handleOpenEditModal = (schedule) => {
    setIsEditMode(true);
    setSelectedSchedule(schedule);
    setFormData({
      dayOfWeek: schedule.dayOfWeek,
      startTime: schedule.startTime.substring(0, 5),
      endTime: schedule.endTime.substring(0, 5),
      room: schedule.room,
      status: schedule.status || 'Sắp học',
      subjectId: schedule.subjectId,
      teacherId: schedule.teacherId,
      classId: schedule.classId
    });
    dialogRef.current?.showModal();
  };

  const handleCloseModal = () => {
    dialogRef.current?.close();
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (isEditMode && selectedSchedule) {
        await api.updateSchedule(selectedSchedule.id, formData);
        showToast('Cập nhật lịch học thành công', 'success');
      } else {
        await api.createSchedule(formData);
        showToast('Tạo lịch học thành công', 'success');
      }
      handleCloseModal();
      fetchSchedules();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Bạn có chắc chắn muốn xóa lịch học này?')) {
      return;
    }
    try {
      await api.deleteSchedule(id);
      showToast('Xóa lịch học thành công', 'success');
      fetchSchedules();
    } catch (err) {
      showToast(err.message, 'error');
    }
  };

  const filteredSchedules = schedules.filter(s => {
    const term = searchTerm.toLowerCase();
    const matchesSearch = (s.className && s.className.toLowerCase().includes(term)) ||
                          (s.teacherName && s.teacherName.toLowerCase().includes(term)) ||
                          (s.subjectName && s.subjectName.toLowerCase().includes(term)) ||
                          (s.room && s.room.toLowerCase().includes(term));
    const matchesDay = filterDay === 'ALL' || s.dayOfWeek.toString() === filterDay;
    return matchesSearch && matchesDay;
  });

  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;

  useEffect(() => {
    setCurrentPage(1);
  }, [searchTerm, filterDay]);

  const totalPages = Math.ceil(filteredSchedules.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const paginatedSchedules = filteredSchedules.slice(startIndex, startIndex + itemsPerPage);

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h2 style={{ fontSize: '1.5rem', marginBottom: '4px' }}>Quản lý lịch học theo Lớp</h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Sắp xếp, quản lý lịch giảng dạy của giáo viên và thời khóa biểu của các lớp</p>
        </div>
        <button className="btn btn-primary" onClick={handleOpenAddModal} disabled={subjects.length === 0 || teachers.length === 0 || classes.length === 0}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
          Thêm lịch học
        </button>
      </div>

      {/* Filter and Search */}
      <div className="glass-card" style={{ padding: '16px', display: 'flex', gap: '16px', marginBottom: '20px', flexWrap: 'wrap' }}>
        <div style={{ flex: '1', minWidth: '200px' }}>
          <input
            type="text"
            className="form-control"
            placeholder="Tìm theo lớp học, giáo viên, môn học, phòng..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <div style={{ width: '180px' }}>
          <select className="form-control form-select" value={filterDay} onChange={(e) => setFilterDay(e.target.value)}>
            <option value="ALL">Tất cả các thứ</option>
            <option value="2">Thứ Hai</option>
            <option value="3">Thứ Ba</option>
            <option value="4">Thứ Tư</option>
            <option value="5">Thứ Năm</option>
            <option value="6">Thứ Sáu</option>
            <option value="7">Thứ Bảy</option>
          </select>
        </div>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px' }}>Đang tải dữ liệu lịch học...</div>
      ) : filteredSchedules.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>Không có lịch học nào phù hợp</div>
      ) : (
        <>
          <div className="glass-card" style={{ padding: 0, overflow: 'hidden' }}>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Thứ</th>
                  <th>Thời gian</th>
                  <th>Lớp học</th>
                  <th>Môn học</th>
                  <th>Giáo viên</th>
                  <th>Phòng học</th>
                  <th>Trạng thái</th>
                  <th style={{ textAlign: 'right' }}>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                {paginatedSchedules.map(schedule => (
                  <tr key={schedule.id}>
                    <td>
                      <span className="badge" style={{ background: 'rgba(243, 111, 33, 0.1)', color: 'var(--color-accent)', fontWeight: '600' }}>
                        {DAYS_OF_WEEK[schedule.dayOfWeek] || `Thứ ${schedule.dayOfWeek}`}
                      </span>
                    </td>
                    <td style={{ fontWeight: '500' }}>
                      {schedule.startTime?.substring(0, 5)} - {schedule.endTime?.substring(0, 5)}
                    </td>
                    <td>
                      <span className="badge badge-student">{schedule.className}</span>
                    </td>
                    <td style={{ fontWeight: '600' }}>{schedule.subjectName}</td>
                    <td>{schedule.teacherName}</td>
                    <td>
                      <span style={{ background: 'rgba(255, 255, 255, 0.05)', padding: '4px 8px', borderRadius: '4px', fontSize: '0.85rem' }}>
                        {schedule.room}
                      </span>
                    </td>
                    <td>
                      <span className={`badge ${schedule.status === 'Đã học' ? 'badge-inactive' : 'badge-active'}`}>
                        {schedule.status || 'Sắp học'}
                      </span>
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                        <button className="btn btn-secondary" style={{ padding: '6px 12px', fontSize: '0.85rem' }} onClick={() => handleOpenEditModal(schedule)}>Sửa</button>
                        <button className="btn btn-secondary" style={{ padding: '6px 12px', fontSize: '0.85rem', color: '#fca5a5', borderColor: 'rgba(239, 68, 68, 0.2)' }} onClick={() => handleDelete(schedule.id)}>Xóa</button>
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

      {/* Modal Dialog for Add/Edit Schedule */}
      <dialog ref={dialogRef} className="modal">
        <div style={{ width: '100%', maxWidth: '500px' }} className="modal-content">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <h3 style={{ fontSize: '1.25rem', fontWeight: '700' }}>
              {isEditMode ? 'Cập nhật lịch học' : 'Thêm lịch học theo Lớp'}
            </h3>
            <button onClick={handleCloseModal} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontSize: '1.2rem' }}>✕</button>
          </div>

          <form onSubmit={handleSubmit}>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div className="form-group">
                <label className="form-label">Thứ trong tuần *</label>
                <select
                  className="form-control form-select"
                  value={formData.dayOfWeek}
                  onChange={(e) => setFormData({ ...formData, dayOfWeek: parseInt(e.target.value, 10) })}
                  required
                >
                  <option value={2}>Thứ Hai</option>
                  <option value={3}>Thứ Ba</option>
                  <option value={4}>Thứ Tư</option>
                  <option value={5}>Thứ Năm</option>
                  <option value={6}>Thứ Sáu</option>
                  <option value={7}>Thứ Bảy</option>
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Phòng học *</label>
                <input
                  type="text"
                  className="form-control"
                  required
                  value={formData.room}
                  onChange={(e) => setFormData({ ...formData, room: e.target.value })}
                  placeholder="Ví dụ: Phòng A201"
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div className="form-group">
                  <label className="form-label">Giờ bắt đầu *</label>
                  <input
                    type="time"
                    className="form-control"
                    required
                    value={formData.startTime}
                    onChange={(e) => setFormData({ ...formData, startTime: e.target.value })}
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Giờ kết thúc *</label>
                  <input
                    type="time"
                    className="form-control"
                    required
                    value={formData.endTime}
                    onChange={(e) => setFormData({ ...formData, endTime: e.target.value })}
                  />
                </div>
              </div>

              <div className="form-group">
                <label className="form-label">Lớp học *</label>
                <select
                  className="form-control form-select"
                  value={formData.classId}
                  onChange={(e) => setFormData({ ...formData, classId: e.target.value })}
                  required
                >
                  <option value="">-- Chọn lớp học --</option>
                  {classes.map(c => (
                    <option key={c.id} value={c.id}>
                      {c.name} {c.homeroomTeacherName ? `(GVCN: ${c.homeroomTeacherName})` : ''}
                    </option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Môn học *</label>
                <select
                  className="form-control form-select"
                  value={formData.subjectId}
                  onChange={(e) => setFormData({ ...formData, subjectId: e.target.value })}
                  required
                >
                  <option value="">-- Chọn môn học --</option>
                  {subjects.map(sub => (
                    <option key={sub.id} value={sub.id}>{sub.name} ({sub.code})</option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Giáo viên giảng dạy *</label>
                <select
                  className="form-control form-select"
                  value={formData.teacherId}
                  onChange={(e) => setFormData({ ...formData, teacherId: e.target.value })}
                  required
                >
                  <option value="">-- Chọn giáo viên --</option>
                  {teachers.map(t => (
                    <option key={t.id} value={t.id}>{t.fullName} ({t.specialization || 'Khác'})</option>
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
                  <option value="Sắp học">Sắp học</option>
                  <option value="Đang học">Đang học</option>
                  <option value="Đã học">Đã học</option>
                  <option value="Đã hủy">Đã hủy</option>
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
