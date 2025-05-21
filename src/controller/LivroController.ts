import { Livro } from "../model/Livro";
import { Request, Response } from "express";
import fs from 'fs';
import path from 'path';
import crypto from 'crypto';

/**
 * Interface LivroDTO
 * Define os atributos que devem ser recebidos do cliente nas requisições
 */
interface LivroDTO {
    titulo: string;
    autor: string;
    editora: string;
    anoPublicacao?: number;
    isbn?: string;
    quantTotal: number;
    quantDisponivel: number;
    valorAquisicao?: number;
    statusLivroEmprestado?: string
}

/**
 * Controlador para operações relacionadas aos Livros.
*/
class LivroController extends Livro {
    /**
     * Lista todos os livros.
     * @param req Objeto de requisição HTTP.
     * @param res Objeto de resposta HTTP.
     * @returns Lista de livros em formato JSON.
     */
    static async todos(req: Request, res: Response) {
        try {
            const listaDeLivros = await Livro.listarLivros();

            res.status(200).json(listaDeLivros);
        } catch (error) {
            console.log(`Erro ao acessar método herdado: ${error}`);

            res.status(400).json("Erro ao recuperar as informações do Livro");
        }
    }

    /**
     * Cadastra um novo livro.
     * @param req Objeto de requisição HTTP com os dados do aluno.
     * @param res Objeto de resposta HTTP.
     * @returns Mensagem de sucesso ou erro em formato JSON.
     */
    static async cadastrar(req: Request, res: Response) {
        try {
            const dadosRecebidos: LivroDTO = req.body;

            // Instanciando objeto Livro
            const novoLivro = new Livro(
                dadosRecebidos.titulo,
                dadosRecebidos.autor,
                dadosRecebidos.editora,
                (dadosRecebidos.anoPublicacao ?? 0).toString(),
                dadosRecebidos.isbn ?? '',
                dadosRecebidos.quantTotal,
                dadosRecebidos.quantDisponivel,
                dadosRecebidos.valorAquisicao ?? 0,
                dadosRecebidos.statusLivroEmprestado ?? 'Disponível'
            );

            // Chama o método para persistir o livro no banco de dados
            const result = await Livro.cadastrarLivro(novoLivro);

            // Verifica se o cadastro foi bem-sucedido
            if (result.queryResult && result.idLivro) {
                novoLivro.setIdLivro(result.idLivro);

                // Inserindo capa do livro, se informada
                // 👇 Pega o nome da imagem que foi salvo no multerConfig.ts
                if (req.file && (req as any).nomeImagemCapa) {
                    const nomeImagem = (req as any).nomeImagemCapa;
                    await Livro.atualizarImagemCapa(nomeImagem, novoLivro.getIdLivro());
                }

                // Retorno de sucesso com o ID do livro
                return res.status(200).json({ mensagem: 'Livro cadastrado com sucesso' });
            } else {
                return res.status(400).json({ mensagem: 'Não foi possível cadastrar o livro no banco de dados' });
            }
        } catch (error) {
            console.error(`Erro ao cadastrar o livro: ${error}`);
            return res.status(500).json({
                mensagem: 'Erro ao cadastrar o livro'
            });
        }
    }

    /**
    * Remove um aluno.
    * @param req Objeto de requisição HTTP com o ID do aluno a ser removido.
    * @param res Objeto de resposta HTTP.
    * @returns Mensagem de sucesso ou erro em formato JSON.
    */
    static async remover(req: Request, res: Response): Promise<Response> {
        try {
            const idLivro = parseInt(req.query.idLivro as string);
            const result = await Livro.removerLivro(idLivro);

            if (result) {
                return res.status(200).json('Livro removido com sucesso');
            } else {
                return res.status(401).json('Erro ao deletar livro');
            }
        } catch (error) {
            console.log("Erro ao remover o Livro");
            console.log(error);
            return res.status(500).send("error");
        }
    }

    /**
     * Método para atualizar o cadastro de um livro.
     *
     * @param req Objeto de requisição do Express, contendo os dados atualizados do aluno
     * @param res Objeto de resposta do Express
     * @returns Retorna uma resposta HTTP indicando sucesso ou falha na atualização
     */
    static async atualizar(req: Request, res: Response): Promise<Response> {
        try {
            const dadosRecebidos: LivroDTO = req.body;

            // Cria uma nova instância de Livro com os dados atualizados
            const livro = new Livro(
                dadosRecebidos.titulo,
                dadosRecebidos.autor,
                dadosRecebidos.editora,
                (dadosRecebidos.anoPublicacao ?? 0).toString(),
                dadosRecebidos.isbn ?? '',
                dadosRecebidos.quantTotal,
                dadosRecebidos.quantDisponivel,
                dadosRecebidos.valorAquisicao ?? 0,
                dadosRecebidos.statusLivroEmprestado ?? 'Disponível'
            );

            // Define o ID do livro, que deve ser passado na query string
            livro.setIdLivro(parseInt(req.query.idLivro as string));

            // Chama o método para atualizar o cadastro do livro no banco de dados
            if (await Livro.atualizarCadastroLivro(livro)) {
                return res.status(200).json({ mensagem: "Cadastro atualizado com sucesso!" });
            } else {
                return res.status(400).json('Não foi possível atualizar o livro no banco de dados');
            }
        } catch (error) {
            // Caso ocorra algum erro, este é registrado nos logs do servidor
            console.error(`Erro no modelo: ${error}`);
            // Retorna uma resposta com uma mensagem de erro
            return res.json({ mensagem: "Erro ao atualizar aluno." });
        }
    }
}

export default LivroController;