import { memo } from "react";

type UserRow = {
  name: string;
  email: string;
  plan: string;
  status: "active" | "pending" | "paused";
  createdAt: string;
};

type TableCardProps = {
  title: string;
  rows: UserRow[];
};

function TableCardComponent({ title, rows }: TableCardProps) {
  return (
    <article className="table-card">
      <div className="card-head">
        <div>
          <h3>{title}</h3>
          <p>Latest onboarding snapshot</p>
        </div>
      </div>

      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>User Name</th>
              <th>Email</th>
              <th>Plan</th>
              <th>Status</th>
              <th>Created At</th>
            </tr>
          </thead>
          <tbody>
            {rows.length === 0 ? (
              <tr>
                <td colSpan={5} className="empty-cell">
                  No users available.
                </td>
              </tr>
            ) : (
              rows.map((row) => (
                <tr key={`${row.email}-${row.createdAt}`}>
                  <td>{row.name}</td>
                  <td>{row.email}</td>
                  <td>{row.plan}</td>
                  <td>
                    <span className={`status-chip status-${row.status}`}>{row.status}</span>
                  </td>
                  <td>{row.createdAt}</td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </article>
  );
}

const TableCard = memo(TableCardComponent);

export default TableCard;
