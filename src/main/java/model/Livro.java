package model;

import java.math.BigDecimal;

public class Livro {
    private int idLivro;
    private String titulo;
    private String autor;
    private String isbn;
    private BigDecimal precoCusto;
    private int quantidadeEstoque;
    private String status;

    public int getIdLivro() {
        return idLivro;
    }

    public void setIdLivro(int idLivro) {
        this.idLivro = idLivro;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getAutor() {
        return autor;
    }

    public void setAutor(String autor) {
        this.autor = autor;
    }

    public String getIsbn() {
        return isbn;
    }

    public void setIsbn(String isbn) {
        this.isbn = isbn;
    }

    public BigDecimal getPrecoCusto() {
        return precoCusto;
    }

    public void setPrecoCusto(BigDecimal precoCusto) {
        if (precoCusto != null && precoCusto.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Preço de custo não pode ser negativo.");
        }
        this.precoCusto = precoCusto;
    }

    public int getQuantidadeEstoque() {
        return quantidadeEstoque;
    }

    public void setQuantidadeEstoque(int quantidadeEstoque) {
        this.quantidadeEstoque = quantidadeEstoque;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "ID: " + idLivro +
                " | Título: " + titulo +
                " | Autor: " + autor +
                " | ISBN: " + isbn +
                " | Preço: " + precoCusto +
                " | Estoque: " + quantidadeEstoque +
                " | Status: " + status;
    }

    public String toStringPublico() {
        return "ID: " + idLivro +
                " | Título: " + titulo +
                " | Autor: " + autor +
                " | ISBN: " + isbn +
                " | Status: " + status;
    }
}
