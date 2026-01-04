package control.system;

import entity.Setup;

public class PaymentSetupResult {

    private Setup setup;

    public PaymentSetupResult(Setup setup) {
        this.setup = setup;
    }

    public Setup getSetup() {
        return setup;
    }
}