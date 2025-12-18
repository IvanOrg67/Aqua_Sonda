const db = require('./database');

/**
 * Query Builder para PostgreSQL - Sintaxis similar a Supabase
 */
class QueryBuilder {
  constructor(table) {
    this.table = table;
    this.selectColumns = '*';
    this.whereConditions = [];
    this.whereParams = [];
    this.joinClauses = [];
    this.orderByClause = '';
    this.limitValue = null;
  }

  select(columns = '*') {
    this.selectColumns = columns;
    return this;
  }

  where(column, operator, value) {
    this.whereConditions.push(`${column} ${operator} $${this.whereParams.length + 1}`);
    this.whereParams.push(value);
    return this;
  }

  eq(column, value) {
    return this.where(column, '=', value);
  }

  neq(column, value) {
    return this.where(column, '!=', value);
  }

  gt(column, value) {
    return this.where(column, '>', value);
  }

  gte(column, value) {
    return this.where(column, '>=', value);
  }

  lt(column, value) {
    return this.where(column, '<', value);
  }

  lte(column, value) {
    return this.where(column, '<=', value);
  }

  like(column, pattern) {
    return this.where(column, 'LIKE', pattern);
  }

  leftJoin(table, condition) {
    this.joinClauses.push(`LEFT JOIN ${table} ON ${condition}`);
    return this;
  }

  innerJoin(table, condition) {
    this.joinClauses.push(`INNER JOIN ${table} ON ${condition}`);
    return this;
  }

  orderBy(column, direction = 'ASC') {
    this.orderByClause = `ORDER BY ${column} ${direction}`;
    return this;
  }

  limit(count) {
    this.limitValue = count;
    return this;
  }

  async execute() {
    let query = `SELECT ${this.selectColumns} FROM ${this.table}`;
    
    if (this.joinClauses.length > 0) {
      query += ' ' + this.joinClauses.join(' ');
    }
    
    if (this.whereConditions.length > 0) {
      query += ' WHERE ' + this.whereConditions.join(' AND ');
    }
    
    if (this.orderByClause) {
      query += ' ' + this.orderByClause;
    }
    
    if (this.limitValue) {
      query += ` LIMIT ${this.limitValue}`;
    }

    const result = await db.query(query, this.whereParams);
    return result.rows;
  }

  async single() {
    this.limit(1);
    const rows = await this.execute();
    return rows.length > 0 ? rows[0] : null;
  }
}

class InsertBuilder {
  constructor(table, data) {
    this.table = table;
    this.data = data;
  }

  async execute() {
    const columns = Object.keys(this.data);
    const values = Object.values(this.data);
    const placeholders = values.map((_, i) => `$${i + 1}`).join(', ');
    
    const query = `
      INSERT INTO ${this.table} (${columns.join(', ')})
      VALUES (${placeholders})
      RETURNING *
    `;
    
    const result = await db.query(query, values);
    return result.rows[0];
  }
}

class UpdateBuilder {
  constructor(table) {
    this.table = table;
    this.updateData = {};
    this.whereConditions = [];
    this.whereParams = [];
  }

  set(data) {
    this.updateData = data;
    return this;
  }

  where(column, operator, value) {
    this.whereConditions.push(`${column} ${operator} $${Object.keys(this.updateData).length + this.whereParams.length + 1}`);
    this.whereParams.push(value);
    return this;
  }

  eq(column, value) {
    return this.where(column, '=', value);
  }

  async execute() {
    const columns = Object.keys(this.updateData);
    const values = Object.values(this.updateData);
    
    const setClause = columns.map((col, i) => `${col} = $${i + 1}`).join(', ');
    
    let query = `UPDATE ${this.table} SET ${setClause}`;
    
    if (this.whereConditions.length > 0) {
      query += ' WHERE ' + this.whereConditions.join(' AND ');
    }
    
    query += ' RETURNING *';
    
    const result = await db.query(query, [...values, ...this.whereParams]);
    return result.rows[0];
  }
}

class DeleteBuilder {
  constructor(table) {
    this.table = table;
    this.whereConditions = [];
    this.whereParams = [];
  }

  where(column, operator, value) {
    this.whereConditions.push(`${column} ${operator} $${this.whereParams.length + 1}`);
    this.whereParams.push(value);
    return this;
  }

  eq(column, value) {
    return this.where(column, '=', value);
  }

  async execute() {
    let query = `DELETE FROM ${this.table}`;
    
    if (this.whereConditions.length > 0) {
      query += ' WHERE ' + this.whereConditions.join(' AND ');
    }
    
    await db.query(query, this.whereParams);
    return { success: true };
  }
}

// Función principal tipo Supabase
function from(table) {
  return new QueryBuilder(table);
}

function insert(table, data) {
  return new InsertBuilder(table, data);
}

function update(table) {
  return new UpdateBuilder(table);
}

function remove(table) {
  return new DeleteBuilder(table);
}

module.exports = {
  from,
  insert,
  update,
  remove,
  delete: remove // Alias
};
