require 'spec_helper'

describe TwistlockControl::Provisioner do
    ##
    # Hoe het wel moet..
    # 
    # Je kan van een service een instance maken. Van
    # die instance kun je dan de 'rollen' enumeraten
    # aan die rollen kun je dan provisioner configuraties
    # koppelen.
    # Daarna kun je op de service instance provision aanroepen.
    # Service instance provision roept op alle rollen provision aan

    it "can provision a service" do
        service = TwistlockControl::Service.new(name: 'MyService')
        container = TwistlockControl::Container.new(name: 'MyContainer', url: 'someUrl')
        service.save
        container.save
        service.add_container(container)
        prov = TwistlockControl::Provisioner.new(name: 'MyName', url: 'url')
        api = double(TwistlockControl::ProvisionerAPI)
        prov.stub(:api).and_return(api)
        expect(api).to receive(:add_container).with('MyContainer', 'someUrl').and_return(true)
        prov.provision(service)
    end

    it "can be initialized from its attributes" do
        prov = TwistlockControl::Provisioner.new(name: 'MyName', url: 'url')
        expect(prov.respond_to? :name).to be(true)
        expect(prov.name).to eq('MyName')
    end

    it "can be persisted and retrieved from the database" do
        prov = TwistlockControl::Provisioner.new(name: 'MyName', url: 'url')
        prov.save
        retrieved = TwistlockControl::Provisioner.find_by_id(prov.id)
        expect(retrieved).to eq(prov)
    end

    it "can get a list of provisioners" do
        (1..3).each do |i|
            prov = TwistlockControl::Provisioner.new(name: "Prov#{i}", url: "url#{i}")
            prov.save
        end
        retrieved = TwistlockControl::Provisioner.all
        expect(retrieved.length).to eq(3)
    end

    it "can remove provisioners" do
        prov = TwistlockControl::Provisioner.new(name: 'MyName', url: 'url')
        prov.save
        prov.remove
        prov = TwistlockControl::Provisioner.find_by_id(prov.id)
        expect(prov).to be_nil
    end
end
