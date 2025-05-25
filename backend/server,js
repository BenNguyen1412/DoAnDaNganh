const express = require("express");
const mysql = require("mysql");
const cors = require("cors");
require("dotenv").config();

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// Kết nối MySQL
const db = mysql.createConnection({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "your_database_name",
});

db.connect((err) => {
  if (err) {
    console.error("❌ Lỗi kết nối MySQL:", err);
    return;
  }
  console.log("✅ Kết nối MySQL thành công!");
});

// Hàm đối chiếu với bảng dong_co
function compareWithDatabase(P_ct, n_sb, T_2, T_1) {
  return new Promise((resolve, reject) => {
    if (T_1 === 0) {
      console.error("❌ Lỗi: T_1 = 0");
      return reject("❌ Lỗi: T_1 không thể bằng 0 (tránh chia cho 0)");
    }

    const query = `
      SELECT * FROM dong_co
      WHERE Cong_suat >= ?
      AND So_vong_quay >= ?
      AND TK_TD >= ? / ?;
    `;
    const params = [P_ct, n_sb, T_2, T_1];

    db.query(query, params, (err, results) => {
      if (err) {
        console.error("❌ Lỗi truy vấn SQL:", err);
        reject("❌ Lỗi truy vấn: " + err.message);
      } else {
        resolve(results);
      }
    });
  });
}

// Hàm đối chiếu u_h với bảng TST
function compareUHWithDatabase(u_hop) {
  return new Promise((resolve, reject) => {
    const rounded_u_hop = Math.round(u_hop);

    const query = `
      SELECT * FROM TST
      WHERE u_h = ?
      ORDER BY ABS(u_h - ?)
      LIMIT 1;
    `;
    const params = [rounded_u_hop, rounded_u_hop];

    db.query(query, params, (err, results) => {
      if (err) {
        console.error("❌ Lỗi truy vấn SQL:", err);
        reject("❌ Lỗi truy vấn bảng TST: " + err.message);
      } else {
        if (results.length === 0) {
          const nearestQuery = `
            SELECT * FROM TST
            ORDER BY ABS(u_h - ?)
            LIMIT 1;
          `;
          db.query(
            nearestQuery,
            [rounded_u_hop],
            (nearestErr, nearestResults) => {
              if (nearestErr) {
                console.error(
                  "❌ Lỗi truy vấn tìm giá trị gần nhất:",
                  nearestErr
                );
                reject(
                  "❌ Lỗi truy vấn tìm giá trị gần nhất: " + nearestErr.message
                );
              } else {
                if (nearestResults.length > 0) {
                  resolve({
                    matchType: "nearest",
                    data: nearestResults[0],
                    originalValue: u_hop,
                    roundedValue: rounded_u_hop,
                  });
                } else {
                  console.error(
                    "❌ Không tìm thấy bất kỳ giá trị nào trong bảng TST"
                  );
                  reject("❌ Không tìm thấy giá trị phù hợp trong bảng TST");
                }
              }
            }
          );
        } else {
          resolve({
            matchType: "exact",
            data: results[0],
            originalValue: u_hop,
            roundedValue: rounded_u_hop,
          });
        }
      }
    });
  });
}

// Hàm tính toán ban đầu
function calculateResults(data) {
  return new Promise((resolve, reject) => {
    try {
      const {
        force,
        velocity,
        diameter,
        T1,
        t1,
        T2,
        t2,
        efficiencyX,
        efficiencyBr,
        efficiencyOi,
        efficiencyKn,
        transmissionX,
        transmissionH,
      } = data;

      const F = parseFloat(force);
      const v = parseFloat(velocity);
      const D = parseFloat(diameter);
      const T_1 = parseFloat(T1);
      const t_1 = parseFloat(t1);
      const T_2 = parseFloat(T2);
      const t_2 = parseFloat(t2);
      const n_x = parseFloat(efficiencyX);
      const n_br = parseFloat(efficiencyBr);
      const n_oi = parseFloat(efficiencyOi);
      const n_kn = parseFloat(efficiencyKn) || 1;
      const u_x = parseFloat(transmissionX);
      const u_h = parseFloat(transmissionH);

      const P_lv = (F * v) / 1000;
      const P_td = (P_lv * (t_1 * T_1 ** 2 + t_2 * T_2 ** 2)) / (t_1 + t_2);
      const n = n_x * n_br ** 2 * n_oi ** 4 * n_kn;
      const P_ct = P_td / n;
      const n_lv = (60000 * v) / (3.14 * D);
      const u_sb = u_x * u_h;
      const n_sb = n_lv * u_sb;

      compareWithDatabase(P_ct, n_sb, T_2, T_1)
        .then((results) => resolve(results))
        .catch((error) => reject(error));
    } catch (error) {
      console.error("❌ Lỗi trong calculateResults:", error);
      reject("❌ Lỗi tính toán: " + error.message);
    }
  });
}

// Endpoint POST: Tính toán ban đầu
app.post("/submit-data", (req, res) => {
  calculateResults(req.body)
    .then((results) => {
      res.json({ message: "✅ Kết quả từ database", results });
    })
    .catch((error) => {
      console.error("❌ Lỗi:", error);
      res.status(500).json({ error });
    });
});

// Hàm in thông tin động cơ
function printMotorDetails(motor) {
  console.log("════════════ THÔNG SỐ ĐỘNG CƠ ════════════");
  console.log(`🆔 Mã hiệu: ${motor.Ki_hieu}`);
  console.log(`⚡ Công suất: ${motor.Cong_suat} kW`);
  console.log(`🔄 Số vòng quay: ${motor.So_vong_quay} vòng/phút`);
  console.log(`🏷️ Loại động cơ: ${motor.Loai_dong_co || "Không có thông tin"}`);
  console.log(`📊 Hệ số công suất (cosφ): ${motor.cos_phi}`);
  console.log(`🔧 Tỉ số truyền: ${motor.TK_TD}`);
  console.log(`🏋️ Khối lượng: ${motor.Khoi_Luong} kg`);
  console.log("═══════════════════════════════════════════");
}

// Endpoint POST: Lấy chi tiết động cơ
app.post("/get-motor-details", (req, res) => {
  try {
    const { motorCode } = req.body;

    if (!motorCode || typeof motorCode !== "string") {
      return res.status(400).json({ error: "Mã động cơ không hợp lệ" });
    }

    const query = "SELECT * FROM dong_co WHERE Ki_hieu = ? LIMIT 1";
    db.query(query, [motorCode.trim()], (err, results) => {
      if (err) {
        console.error("❌ Lỗi truy vấn:", err);
        return res.status(500).json({ error: "Lỗi database" });
      }

      if (results.length === 0) {
        return res.status(404).json({ error: "Không tìm thấy động cơ" });
      }

      const motor = results[0];
      printMotorDetails(motor);

      res.json({
        motor: {
          code: motor.Ki_hieu,
          power: motor.Cong_suat,
          rpm: motor.So_vong_quay,
          type: motor.Loai_dong_co,
          powerFactor: motor.cos_phi,
          transmissionRatio: motor.TK_TD,
          weight: motor.Khoi_Luong,
        },
      });
    });
  } catch (error) {
    console.error("❌ Lỗi hệ thống:", error);
    res.status(500).json({ error: "Lỗi server" });
  }
});

// Hàm tính toán đầy đủ với động cơ đã chọn
async function performFullCalculation(motorData, originalData) {
  try {
    const F = parseFloat(originalData.force);
    const v = parseFloat(originalData.velocity);
    const D = parseFloat(originalData.diameter);
    const T_1 = parseFloat(originalData.T1);
    const t_1 = parseFloat(originalData.t1);
    const T_2 = parseFloat(originalData.T2);
    const t_2 = parseFloat(originalData.t2);
    const n_x = parseFloat(originalData.efficiencyX);
    const n_br = parseFloat(originalData.efficiencyBr);
    const n_oi = parseFloat(originalData.efficiencyOi);
    const n_kn = parseFloat(originalData.efficiencyKn) || 1;
    const u_x = parseFloat(originalData.transmissionX);
    const u_h = parseFloat(originalData.transmissionH);
    const P_dc = parseFloat(motorData.power);
    const n_dc = parseFloat(motorData.rpm);
    const TK_TDn = parseFloat(motorData.transmissionRatio);
    const m_dc = parseFloat(motorData.weight);

    const P_lv = (F * v) / 1000;
    const P_td = (P_lv * (t_1 * T_1 ** 2 + t_2 * T_2 ** 2)) / (t_1 + t_2);
    const n = n_x * n_br ** 2 * n_oi ** 4 * n_kn;
    const P_ct = P_td / n;
    const n_lv = (60000 * v) / (3.14 * D);
    const u_sb = u_x * u_h;
    const n_sb = n_lv * u_sb;
    const u_t = n_dc / n_lv;
    const u_hop = u_t / u_x;
    const rounded_u_hop = Math.round(u_hop);

    const uComparison = await compareUHWithDatabase(rounded_u_hop);

    const u_xm = u_t / (uComparison.data.u_1 * uComparison.data.u_2);

    const P_3 = P_lv / (n_oi * n_x);
    const P_2 = P_3 / (n_oi * n_br);
    const P_1 = P_2 / (n_oi * n_br);
    const P_dc1 = P_1 / (n_oi * n_kn);

    const n_1 = n_dc;
    const n_2 = n_1 / uComparison.data.u_1;
    const n_3 = n_2 / uComparison.data.u_2;
    const n_ct = n_3 / u_x;

    const T_ct = 9.55 * 10 ** 6 * (P_ct / n_ct);
    const T3 = 9.55 * 10 ** 6 * (P_3 / n_3);
    const T2 = 9.55 * 10 ** 6 * (P_2 / n_2);
    const T1 = 9.55 * 10 ** 6 * (P_1 / n_1);
    const T_dc = 9.55 * 10 ** 6 * (P_dc / n_dc);

    return {
      motorInfo: motorData,
      systemParams: {
        P_lv: P_lv.toFixed(2),
        P_1: P_1.toFixed(2),
        P_2: P_2.toFixed(2),
        P_3: P_3.toFixed(2),
        P_td: P_td.toFixed(2),
        n: n.toFixed(2),
        P_ct: P_ct.toFixed(2),
        n_lv: n_lv.toFixed(2),
        u_sb: u_sb.toFixed(2),
        n_sb: n_sb.toFixed(2),
        u_t: u_t.toFixed(2),
        u_hop: u_hop.toFixed(2),
        rounded_u_hop,
        u_h_matched: uComparison.data.u_h.toFixed(2),
        u_1: uComparison.data.u_1.toFixed(2),
        u_2: uComparison.data.u_2.toFixed(2),
        u_xm: u_xm.toFixed(2),
        matchType: uComparison.matchType,
        P_dc1: P_dc1.toFixed(2),
        n_1: n_1.toFixed(2),
        n_dc: n_dc.toFixed(2),
        n_2: n_2.toFixed(2),
        n_3: n_3.toFixed(2),
        n_ct: n_ct.toFixed(2),
        T_dc: T_dc.toFixed(2),
        T1: T1.toFixed(2),
        T2: T2.toFixed(2),
        T3: T3.toFixed(2),
        T_ct: T_ct.toFixed(2),
      },
    };
  } catch (error) {
    console.error("❌ Lỗi trong performFullCalculation:", error);
    throw new Error("Lỗi tính toán: " + error.message);
  }
}

// Endpoint POST: Tính toán với động cơ đã chọn
app.post("/calculate-with-motor", async (req, res) => {
  try {
    const fullResults = await performFullCalculation(
      req.body.motorData,
      req.body.originalData
    );
    res.json({
      success: true,
      results: fullResults,
    });
  } catch (error) {
    console.error("❌ Lỗi tính toán:", error);
    res.status(500).json({
      success: false,
      error: "Lỗi tính toán hệ thống: " + error.message,
    });
  }
});

// Endpoint POST: Lưu lịch sử tính toán
app.post("/save-calculation", (req, res) => {
  try {
    const { inputParams, motorInfo, calculationResults } = req.body;

    if (!inputParams || !motorInfo || !calculationResults) {
      return res.status(400).json({ error: "Dữ liệu đầu vào không đầy đủ" });
    }

    const query = `
      INSERT INTO calculation_history (input_params, motor_info, calculation_results, motor_type, calculation_date)
      VALUES (?, ?, ?, ?, NOW())
    `;
    const params = [
      JSON.stringify(inputParams),
      JSON.stringify(motorInfo),
      JSON.stringify(calculationResults),
      motorInfo.type || "Unknown",
    ];

    db.query(query, params, (err, result) => {
      if (err) {
        console.error("❌ Lỗi lưu lịch sử tính toán:", err);
        return res.status(500).json({ error: "Lỗi lưu vào database" });
      }

      console.log("✅ Đã lưu lịch sử tính toán, ID:", result.insertId);
      res.json({ success: true, id: result.insertId });
    });
  } catch (error) {
    console.error("❌ Lỗi hệ thống:", error);
    res.status(500).json({ error: "Lỗi server" });
  }
});

// Endpoint GET: Lấy danh sách lịch sử tính toán
app.get("/calculation-history", (req, res) => {
  try {
    const { date, type, page = 1, limit = 10 } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);

    let query = `
      SELECT id, calculation_date, input_params, motor_info, calculation_results, motor_type
      FROM calculation_history
      WHERE 1=1
    `;
    const params = [];

    if (date) {
      query += ` AND DATE(calculation_date) = ?`;
      params.push(date);
    }

    if (type && type !== "all") {
      query += ` AND motor_type = ?`;
      params.push(type);
    }

    let countQuery = `
      SELECT COUNT(*) as total
      FROM calculation_history
      WHERE 1=1
    `;
    const countParams = [];

    if (date) {
      countQuery += ` AND DATE(calculation_date) = ?`;
      countParams.push(date);
    }

    if (type && type !== "all") {
      countQuery += ` AND motor_type = ?`;
      countParams.push(type);
    }

    query += ` ORDER BY calculation_date DESC LIMIT ? OFFSET ?`;
    params.push(parseInt(limit), parseInt(offset));

    db.query(countQuery, countParams, (countErr, countResults) => {
      if (countErr) {
        console.error("❌ Lỗi truy vấn tổng số bản ghi:", countErr);
        return res.status(500).json({ error: "Lỗi database" });
      }

      const total = countResults[0].total;

      db.query(query, params, (err, results) => {
        if (err) {
          console.error("❌ Lỗi truy vấn lịch sử:", err);
          return res.status(500).json({ error: "Lỗi database" });
        }

        const parsedResults = results.map((row) => ({
          id: row.id,
          calculation_date: row.calculation_date,
          inputParams: JSON.parse(row.input_params || "{}"),
          motorInfo: JSON.parse(row.motor_info || "{}"),
          calculationResults: JSON.parse(row.calculation_results || "{}"),
          motor_type: row.motor_type,
        }));

        res.json({ success: true, data: parsedResults, total });
      });
    });
  } catch (error) {
    console.error("❌ Lỗi hệ thống:", error);
    res.status(500).json({ error: "Lỗi server" });
  }
});

// Endpoint GET: Lấy chi tiết lịch sử
app.get("/calculation-history/:id", (req, res) => {
  try {
    const { id } = req.params;

    const query = `
      SELECT id, calculation_date, input_params, motor_info, calculation_results, motor_type
      FROM calculation_history
      WHERE id = ?
    `;
    db.query(query, [id], (err, results) => {
      if (err) {
        console.error("❌ Lỗi truy vấn chi tiết lịch sử:", err);
        return res.status(500).json({ error: "Lỗi database" });
      }

      if (results.length === 0) {
        return res.status(404).json({ error: "Không tìm thấy bản ghi" });
      }

      const row = results[0];
      const parsedResult = {
        id: row.id,
        calculation_date: row.calculation_date,
        inputParams: JSON.parse(row.input_params || "{}"),
        motorInfo: JSON.parse(row.motor_info || "{}"),
        calculationResults: JSON.parse(row.calculation_results || "{}"),
        motor_type: row.motor_type,
      };

      res.json({ success: true, data: parsedResult });
    });
  } catch (error) {
    console.error("❌ Lỗi hệ thống:", error);
    res.status(500).json({ error: "Lỗi server" });
  }
});

// Endpoint DELETE: Xóa lịch sử và cập nhật thứ tự ID
app.delete("/calculation-history/:id", (req, res) => {
  try {
    const { id } = req.params;

    // Bắt đầu transaction để đảm bảo tính toàn vẹn dữ liệu
    db.beginTransaction((err) => {
      if (err) {
        console.error("❌ Lỗi bắt đầu transaction:", err);
        return res.status(500).json({ error: "Lỗi database" });
      }

      // Bước 1: Xóa bản ghi
      const deleteQuery = `DELETE FROM calculation_history WHERE id = ?`;
      db.query(deleteQuery, [id], (err, results) => {
        if (err) {
          db.rollback(() => {
            console.error("❌ Lỗi xóa bản ghi:", err);
            res.status(500).json({ error: "Lỗi database" });
          });
          return;
        }
        if (results.affectedRows === 0) {
          db.rollback(() => {
            res.status(404).json({ error: "Bản ghi không tồn tại" });
          });
          return;
        }

        // Bước 2: Cập nhật ID của các bản ghi có ID lớn hơn
        const updateQuery = `UPDATE calculation_history SET id = id - 1 WHERE id > ?`;
        db.query(updateQuery, [id], (err) => {
          if (err) {
            db.rollback(() => {
              console.error("❌ Lỗi cập nhật ID:", err);
              res.status(500).json({ error: "Lỗi database" });
            });
            return;
          }

          // Bước 3: Cập nhật AUTO_INCREMENT
          const getMaxIdQuery = `SELECT MAX(id) as maxId FROM calculation_history`;
          db.query(getMaxIdQuery, (err, results) => {
            if (err) {
              db.rollback(() => {
                console.error("❌ Lỗi lấy max ID:", err);
                res.status(500).json({ error: "Lỗi database" });
              });
              return;
            }

            const maxId = results[0].maxId || 0;
            const setAutoIncrementQuery = `ALTER TABLE calculation_history AUTO_INCREMENT = ?`;
            db.query(setAutoIncrementQuery, [maxId + 1], (err) => {
              if (err) {
                db.rollback(() => {
                  console.error("❌ Lỗi cập nhật AUTO_INCREMENT:", err);
                  res.status(500).json({ error: "Lỗi database" });
                });
                return;
              }

              // Commit transaction
              db.commit((err) => {
                if (err) {
                  db.rollback(() => {
                    console.error("❌ Lỗi commit transaction:", err);
                    res.status(500).json({ error: "Lỗi database" });
                  });
                  return;
                }

                console.log(
                  "✅ Đã xóa bản ghi ID:",
                  id,
                  "và cập nhật thứ tự ID"
                );
                res.json({ success: true });
              });
            });
          });
        });
      });
    });
  } catch (error) {
    console.error("❌ Lỗi hệ thống:", error);
    res.status(500).json({ error: "Lỗi server" });
  }
});

// Khởi động server
app.listen(PORT, () => {
  console.log(`\n🚀 Server đang chạy tại http://localhost:${PORT}`);
});

// Xuất db để sử dụng ở nơi khác (nếu cần)
module.exports = db;
