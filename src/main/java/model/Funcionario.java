package model;

public class Funcionario extends Usuario {
    @Override
    public int getDiasPrazoEmprestimo() {
        return 14;
    }
}