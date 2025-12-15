# Online Bookstore

这是一个基于 Python Flask 和 Microsoft SQL Server 构建的在线书店 Web 应用程序。

## 📋 功能特性

- **用户系统**：用户注册、登录和注销。
- **图书浏览**：首页展示热门书籍和分类。
- **图书搜索**：支持按书名、ISBN 或出版社搜索。
- **图书详情**：查看书籍的详细信息。
- **分类浏览**：按类别筛选书籍。

## 🛠️ 技术栈

- **后端**：Python 3.x, Flask
- **数据库**：Microsoft SQL Server
- **数据库驱动**：pyodbc
- **安全**：bcrypt (密码哈希)
- **前端**：HTML, Jinja2 模板

## 🚀 快速开始

### 前置要求

1.  安装 [Python 3.x](https://www.python.org/)。
2.  安装 [Microsoft SQL Server](https://www.microsoft.com/sql-server)。
3.  安装 [ODBC Driver 17 for SQL Server](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server)。

### 安装步骤

1.  **克隆或下载项目** 到本地。

2.  **安装依赖**：
    在项目根目录下运行终端命令：
    ```bash
    pip install -r requirements.txt
    ```

3.  **配置数据库**：
    - 确保 SQL Server 正在运行。
    - 使用项目中的 `OnlineBookstore.sql` 脚本初始化数据库结构和数据。
    - 打开 `app.py`，找到 `get_db` 函数，根据你的数据库环境修改连接字符串（SERVER, UID, PWD）：
      ```python
      conn = pyodbc.connect(
          'DRIVER={ODBC Driver 17 for SQL Server};'
          'SERVER=.;'          # 数据库服务器地址
          'DATABASE=OnlineBookstore;'
          'UID=sa;'            # 数据库用户名
          'PWD=123456;'        # 数据库密码
          'TrustServerCertificate=yes;'
      )
      ```

4.  **运行应用**：
    ```bash
    python app.py
    ```

5.  **访问应用**：
    打开浏览器访问 `http://127.0.0.1:5000`。

## 📂 项目结构

- `app.py`: 应用程序的主入口，包含路由和逻辑。
- `templates/`: 存放 HTML 模板文件。
- `static/`: (如果有) 存放 CSS, JS, 图片等静态文件。
- `OnlineBookstore.sql`: 数据库初始化脚本。
- `requirements.txt`: Python 依赖列表。

## ⚠️ 注意事项

- 当前数据库连接包含硬编码的凭据，生产环境中请务必使用环境变量。
- 确保 SQL Server 的 TCP/IP 协议已启用，以便 `pyodbc` 可以连接。
