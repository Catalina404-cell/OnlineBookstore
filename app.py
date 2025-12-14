# app.py
from flask import Flask, render_template, request, redirect, url_for, session, flash
import bcrypt
import pyodbc
from contextlib import contextmanager  # 引入上下文管理器工具

app = Flask(__name__)
# 建议将密钥存储在环境变量中，而不是硬编码
app.secret_key = '$2b$12$LpK6v2f7t9x9v7f8u5s4rO3i2u1y9t8r7e6w5q4e3r2t1y9u8i8o7'

# 让pyodbc返回字典形式的行
class DictRow(dict):
    def __getattr__(self, name):
        try:
            return self[name]
        except KeyError:
            raise AttributeError(f"'dict' object has no attribute '{name}'")

pyodbc.Row = DictRow

# 使用上下文管理器管理数据库连接，自动处理连接的打开和关闭
@contextmanager
def get_db():
    conn = None
    try:
        conn = pyodbc.connect(
            'DRIVER={ODBC Driver 17 for SQL Server};'
            'SERVER=.;'
            'DATABASE=OnlineBookstore;'
            'UID=sa;'
            'PWD=123456;'
            'TrustServerCertificate=yes;'
        )
        yield conn
    except pyodbc.Error as e:
        print(f"数据库连接错误: {e}")
        if conn:
            conn.rollback()
        raise
    finally:
        if conn:
            conn.close()

# 首页
# 首页 - 修改这里！！！
@app.route('/')
def index():
    try:
        with get_db() as conn:
            cursor = conn.cursor()

            # 热门书籍：TOP 12，按评分降序（你目前没有销量字段，用 rating 代替）
            cursor.execute("""
                SELECT TOP 12 
                    book_id, title, isbn, price, cover_url, rating, publisher
                FROM books 
                ORDER BY rating DESC, book_id
            """)
            hot_books = cursor.fetchall()

            # 主分类（parent_id IS NULL）
            cursor.execute("""
                SELECT category_id, category_name 
                FROM categories 
                WHERE parent_id IS NULL 
                ORDER BY category_name
            """)
            main_categories = cursor.fetchall()

        return render_template('index.html', 
                               hot_books=hot_books, 
                               categories=main_categories)
    except Exception as e:
        flash(f"加载首页失败: {str(e)}", 'danger')
        return render_template('index.html', hot_books=hot_books, categories=main_categories,current_category=None)
@app.route('/search')
def search():
    keyword = request.args.get('q', '').strip()
    cat_id = request.args.get('category', type=int)  # 安全获取整数
    
    try:
        with get_db() as conn:
            cursor = conn.cursor()

            query = """
                SELECT 
                    b.book_id, b.title, b.isbn, b.price, 
                    b.cover_url, b.rating, b.publisher
                FROM books b
                WHERE 1=1
            """
            params = []

            if keyword:
                query += " AND (b.title LIKE ? OR b.isbn LIKE ? OR b.publisher LIKE ?)"
                pattern = f"%{keyword}%"
                params.extend([pattern, pattern, pattern])

            if cat_id:
                query += """
                    AND b.book_id IN (
                        SELECT bc.book_id
                        FROM book_categories bc
                        WHERE bc.category_id = ?
                           OR bc.category_id IN (
                               SELECT category_id 
                               FROM categories 
                               WHERE parent_id = ?
                           )
                    )
                """
                params.append(cat_id)
                params.append(cat_id)

            query += " ORDER BY b.rating DESC, b.book_id"

            cursor.execute(query, params)
            books = cursor.fetchall()

            # 关键：必须查询主分类并传给模板！否则 base.html 的左侧分类不显示
            cursor.execute("""
                SELECT category_id, category_name 
                FROM categories 
                WHERE parent_id IS NULL 
                ORDER BY category_name
            """)
            main_categories = cursor.fetchall()

        # 必须传 categories，否则 base.html 渲染失败
        return render_template('search.html', 
                               books=books, 
                               keyword=keyword, 
                               categories=main_categories)
    except Exception as e:
        flash(f"搜索失败: {str(e)}", 'danger')
        # 出错时也要传 categories
        with get_db() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT category_id, category_name FROM categories WHERE parent_id IS NULL ORDER BY category_name")
            main_categories = cursor.fetchall()
        return render_template('search.html', books=[], keyword=keyword, categories=main_categories)
# 辅助函数：获取全部分类（用于导航栏）
@app.route('/book/<int:book_id>')
def book_detail(book_id):
    try:
        with get_db() as conn:
            cursor = conn.cursor()

            # 1. 获取书籍基本信息
            cursor.execute("""
                SELECT 
                    book_id, title, isbn, price, publisher, 
                    publish_date, description, cover_url, rating
                FROM books 
                WHERE book_id = ?
            """, (book_id,))
            book = cursor.fetchone()
            if not book:
                flash('书籍不存在', 'danger')
                return redirect(url_for('index'))

            # 2. 获取所有作者
            cursor.execute("""
                SELECT a.author_name, a.brief
                FROM authors a
                JOIN book_authors ba ON a.author_id = ba.author_id
                WHERE ba.book_id = ?
            """, (book_id,))
            authors = cursor.fetchall()

            # 3. 获取所有分类（包括父分类完整路径）
            cursor.execute("""
                SELECT c.category_id, c.category_name, p.category_name AS parent_name
                FROM categories c
                LEFT JOIN categories p ON c.parent_id = p.category_id
                JOIN book_categories bc ON c.category_id = bc.category_id
                WHERE bc.book_id = ?
            """, (book_id,))
            categories = cursor.fetchall()

            # 4. 获取库存（可选显示）
            cursor.execute("SELECT stock_num FROM inventory WHERE book_id = ?", (book_id,))
            stock_row = cursor.fetchone()
            stock_num = stock_row.stock_num if stock_row else 0

        return render_template('book_detail.html',
                               book=book,
                               authors=authors,
                               categories=categories,
                               stock_num=stock_num)
    except Exception as e:
        flash(f"加载书籍详情失败: {str(e)}", 'danger')
        return redirect(url_for('index'))
def get_categories():
    try:
        with get_db() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT category_id, name, parent_id FROM Categories ORDER BY parent_id, name")
            return cursor.fetchall()
    except Exception as e:
        print(f"获取分类失败: {e}")
        return []

# 注册
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '').strip()
        email = request.form.get('email', '').strip()

        # 简单的表单验证
        if not all([username, password, email]):
            flash('所有字段都必须填写', 'danger')
            return render_template('register.html')

        hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

        try:
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute(
                "INSERT INTO users (username, password, email) VALUES (?, ?, ?)",
                (username, hashed.decode('utf-8'), email)   # 还是存加密后的密码，只是字段叫 password
)
                conn.commit()
                flash('注册成功！请登录', 'success')
                return redirect(url_for('login'))
        except pyodbc.IntegrityError:
            flash('用户名或邮箱已存在', 'danger')
        except Exception as e:
            flash(f'注册失败: {str(e)}', 'danger')

    return render_template('register.html')

# 登录
@app.route('/login', methods=['GET', 'POST'])
def login():
    if 'user_id' in session:
        return redirect(url_for('index'))
        
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '').strip()

        if not all([username, password]):
            flash('用户名和密码都必须填写', 'danger')
            return render_template('login.html')

        try:
            with get_db() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT user_id, password, username FROM users WHERE username = ?", (username,))
                user = cursor.fetchone()

                if user is None:
                    flash('用户名或密码错误', 'danger')
                    return render_template('login.html')
                if bcrypt.checkpw(password.encode('utf-8'), user.password.encode('utf-8')):
                    session['user_id'] = user.user_id
                    session['username'] = user.username
                    session['is_admin'] = False  # 暂时都设为普通用户
                    flash('登录成功！', 'success')
                    return redirect(url_for('index'))
                else:
                    flash('用户名或密码错误', 'danger')

        except Exception as e:
            flash(f'登录失败: {str(e)}', 'danger')

    return render_template('login.html')
# 登出功能
@app.route('/logout')
def logout():
    session.clear()
    flash('已成功登出', 'success')
    return redirect(url_for('index'))

if __name__ == '__main__':
    # 生产环境中应设置debug=False
    app.run(debug=True, port=5000)