package model;

public class Aluno extends Usuario {
    @Override
    public int getDiasPrazoEmprestimo() {
        return 7;
    }
}