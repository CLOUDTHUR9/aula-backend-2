/*
-- Drop da trigger
DROP TRIGGER IF EXISTS trg_gerar_ra ON Aluno;

-- Drop da função
DROP FUNCTION IF EXISTS gerar_ra();

-- Drop da tabela Emprestimo
DROP TABLE IF EXISTS Emprestimo;

-- Drop da tabela Livro
DROP TABLE IF EXISTS Livro;

-- Drop da tabela Aluno
DROP TABLE IF EXISTS Aluno;

-- Drop da sequência
DROP SEQUENCE IF EXISTS seq_ra;
*/

-- Habilitar a extensão para geração de UUIDs
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE SEQUENCE seq_ra START 1;

CREATE TABLE IF NOT EXISTS Aluno (
    id_aluno SERIAL PRIMARY KEY,
    ra VARCHAR (7) UNIQUE NOT NULL,
    nome VARCHAR (80) NOT NULL,
    sobrenome VARCHAR (80) NOT NULL,
    data_nascimento DATE,
    endereco VARCHAR (200),
    email VARCHAR (80),
    celular VARCHAR (20) NOT NULL
);

-- Criar a função gerar_ra apenas se não existir
CREATE OR REPLACE FUNCTION gerar_ra() RETURNS TRIGGER AS $$
BEGIN
    NEW.ra := 'AAA' || TO_CHAR(nextval('seq_ra'), 'FM0000');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar a trigger trg_gerar_ra apenas se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_gerar_ra') THEN
        CREATE TRIGGER trg_gerar_ra
        BEFORE INSERT ON Aluno
        FOR EACH ROW EXECUTE FUNCTION gerar_ra();
    END IF;
END $$;

-- CREATE LIVRO
CREATE TABLE IF NOT EXISTS Livro (
    id_livro SERIAL PRIMARY KEY,
    titulo VARCHAR (200) NOT NULL,
    autor VARCHAR (150) NOT NULL,
    editora VARCHAR (100) NOT NULL,
    ano_publicacao VARCHAR (5),
    isbn VARCHAR (20),
    quant_total INTEGER NOT NULL,
    quant_disponivel INTEGER NOT NULL,
    valor_aquisicao DECIMAL (10,2),
    status_livro_emprestado VARCHAR (20)
);

-- CREATE EMPRESTIMO
CREATE TABLE IF NOT EXISTS Emprestimo (
    id_emprestimo SERIAL PRIMARY KEY,
    id_aluno INT REFERENCES Aluno(id_aluno),
    id_livro INT REFERENCES Livro(id_livro),
    data_emprestimo DATE NOT NULL,
    data_devolucao DATE,
    status_emprestimo VARCHAR (20)
);

-- CREATE USUARIOS
CREATE TABLE IF NOT EXISTS Usuario (
    id_usuario SERIAL PRIMARY KEY,
    uuid UUID DEFAULT gen_random_uuid() NOT NULL,
    nome VARCHAR(70) NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(50) UNIQUE NOT NULL,
    senha VARCHAR(50) NOT NULL
);

-- Criar a função gerar_senha_padrao apenas se não existir
CREATE OR REPLACE FUNCTION gerar_senha_padrao()
RETURNS TRIGGER AS $$
BEGIN
    NEW.senha := NEW.username || '1234';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar a trigger trigger_gerar_senha apenas se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_gerar_senha') THEN
        CREATE TRIGGER trigger_gerar_senha
        BEFORE INSERT ON Usuario
        FOR EACH ROW
        EXECUTE FUNCTION gerar_senha_padrao();
    END IF;
END $$;

-- Criar as colunas na tabela Aluno, Emprestimo e Livro, se ainda não existirem
ALTER TABLE IF EXISTS Aluno ADD COLUMN IF NOT EXISTS status_aluno BOOLEAN DEFAULT TRUE;
ALTER TABLE IF EXISTS Emprestimo ADD COLUMN IF NOT EXISTS status_emprestimo_registro BOOLEAN DEFAULT TRUE;
ALTER TABLE IF EXISTS Livro ADD COLUMN IF NOT EXISTS status_livro BOOLEAN DEFAULT TRUE;


-- Inserindo usuarios
INSERT INTO usuario (nome, username, email) 
VALUES
('João Silva', 'joao.silva', 'joao.silva@email.com'),
('Maria Oliveira', 'maria.oliveira', 'maria.oliveira@email.com'),
('Carlos Souza', 'carlos.souza', 'carlos.souza@email.com');

-- Aluno
INSERT INTO Aluno (nome, sobrenome, data_nascimento, endereco, email, celular) 
VALUES 
('Neil', 'Armstrong', '1930-08-05', 'Rua Apollo, 11', 'neil.armstrong@nasa.com', '16988951234'),
('Ada', 'Lovelace', '1815-12-10', 'Rua Algoritmo, 88', 'ada.lovelace@ti.com', '16990985566'),
('Tim', 'Berners-Lee', '1955-06-08', 'Rua Web, 1010', 'tim.berners@web.com', '16985993212'),
('Marie', 'Curie', '1867-11-07', 'Rua Radioatividade, 1900', 'marie.curie@nobel.com', '16983921157'),
('Albert', 'Einstein', '1879-03-14', 'Rua Relatividade, 1879', 'albert.einstein@nobel.com', '16984995012'),
('Sally', 'Ride', '1951-05-26', 'Rua Espacial, 77', 'sally.ride@nasa.com', '16985995544'),
('Linus', 'Torvalds', '1969-12-28', 'Rua Kernel, 99', 'linus.torvalds@linux.com', '16980992234'),
('Alan', 'Turing', '1912-06-23', 'Rua Máquina, 300', 'alan.turing@enigma.com', '16981994456'),
('Dorothy', 'Hodgkin', '1910-05-12', 'Rua Cristalografia, 45', 'dorothy.hodgkin@nobel.com', '16983990011'),
('Elon', 'Musk', '1971-06-28', 'Rua SpaceX, 2021', 'elon.musk@spacex.com', '16985992201');

--livros
INSERT INTO Livro (titulo, autor, editora, ano_publicacao, isbn, quant_total, quant_disponivel, valor_aquisicao, status_livro_emprestado) 
VALUES 
('Clean Code: A Handbook of Agile Software Craftsmanship', 'Robert C. Martin', 'Prentice Hall', 2008, '978-0132350884', 10, 10, 200.00, 'Disponível'),
('The Pragmatic Programmer: Your Journey to Mastery', 'Andrew Hunt, David Thomas', 'Addison-Wesley', 1999, '978-0201616224', 8, 8, 180.00, 'Disponível'),
('Design Patterns: Elements of Reusable Object-Oriented Software', 'Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides', 'Addison-Wesley', 1994, '978-0201633610', 6, 6, 150.00, 'Disponível'),
('Eloquent JavaScript: A Modern Introduction to Programming', 'Marijn Haverbeke', 'No Starch Press', 2018, '978-1593279509', 9, 9, 85.00, 'Disponível'),
('Learning Web Design: A Beginner’s Guide to HTML, CSS, JavaScript, and Web Graphics', 'Jennifer Niederst Robbins', 'O''''Reilly Media', 2018, '978-1491960202', 7, 7, 95.00, 'Disponível'),
('HTML and CSS: Design and Build Websites', 'Jon Duckett', 'Wiley', 2011, '978-1118008188', 10, 10, 90.00, 'Disponível'),
('JavaScript and JQuery: Interactive Front-End Web Development', 'Jon Duckett', 'Wiley', 2014, '978-1118531648', 5, 5, 100.00, 'Disponível'),
('The Mythical Man-Month: Essays on Software Engineering', 'Frederick P. Brooks Jr.', 'Addison-Wesley', 1975, '978-0201835953', 4, 4, 130.00, 'Disponível'),
('Introduction to Algorithms', 'Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest, Clifford Stein', 'MIT Press', 2009, '978-0262033848', 6, 6, 250.00, 'Disponível'),
('Refactoring: Improving the Design of Existing Code', 'Martin Fowler', 'Addison-Wesley', 1999, '978-0201485677', 5, 5, 170.00, 'Disponível');

--Empréstimo 
INSERT INTO Emprestimo (id_aluno, id_livro, data_emprestimo, data_devolucao, status_emprestimo) 
VALUES 
(11, 12, '2024-09-01', '2024-09-15', 'Concluído'),
(13, 14, '2024-09-02', '2024-09-16', 'Concluído'),
(15, 11, '2024-09-03', '2024-09-17', 'Atrasado'),
(17, 13, '2024-09-04', '2024-09-18', 'Atrasado'),
(19, 15, '2024-09-05', '2024-09-19', 'Concluído'),
(12, 16, '2024-09-06', '2024-09-20', 'Em andamento'),
(14, 18, '2024-09-07', '2024-09-21', 'Em andamento'),
(16, 17, '2024-09-08', '2024-09-22', 'Atrasado'),
(18, 20, '2024-09-09', '2024-09-23', 'Concluído'),
(20, 19, '2024-09-10', '2024-09-24', 'Em andamento'),
(11, 18, '2024-09-11', '2024-09-25', 'Concluído'),
(13, 17, '2024-09-11', '2024-09-25', 'Atrasado'),
(15, 16, '2024-09-11', '2024-09-25', 'Em andamento'),
(17, 14, '2024-09-11', '2024-09-25', 'Concluído');
