package org.bazile.jenkins.python.utils;

import hudson.model.Computer;
import hudson.model.Node;

import javax.annotation.Nonnull;
import java.io.IOException;

public enum Platform {
    Linux,
    MacOS,
    Unknown;

    public static Platform detect(@Nonnull Node node) throws DetectionFailed {
        Computer computer = node.toComputer();
        if (computer == null) {
            throw new DetectionFailed("node conversion failed");
        }

        String raw;
        try {
            raw = computer.getSystemProperties().get("os.name").toString().toLowerCase();
        }
        catch (IOException | InterruptedException | NullPointerException e) {
            throw new DetectionFailed("could not read node properties");
        }

        if (raw.contains("os x")) {
            return MacOS;
        }

        if (raw.contains("linux")) {
            return Linux;
        }

        return Unknown;
    }

    @Override
    public String toString() {
        return super.toString().toLowerCase();
    }

    private static class DetectionFailed extends RuntimeException {
        public DetectionFailed(String message) {
            super(message);
        }
    }
}
